From: jt@bougret.hpl.hp.com
Subject: Re: NETLINK upcalls and wireless events
Date: Tue, 23 Mar 2004 09:57:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323175717.GA32055__33632.2284806103$1080065826@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: hostap@shmoo.com
Content-Disposition: inline
Resent-Message-Id: <E1B5qQX-00007c-00@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pavlin Radoslavov wrote :
> 
> I am using Linux NETLINK sockets to monitor network interface events
> in the kernel such as "interface added/deleted", "address
> added/deleted", etc.
[...]
> In other words, some wireless events may also generate RTM_NEWLINK
> message as well. I don't have a laptop with Linux to verify that
> myself, but I am quite sure that some wireless events do generate
> RTM_NEWLINK with no IFLA_IFNAME.
[...]
> If I receive an RTM_NEWLINK message, is there a reliable way to
> find-out whether the message is generated because of a wireless
> event or because indeed there is a new network interface installed
> in the kernel.
> 
> Checking whether the message contains the IFLA_WIRELESS field is
> probably not an option, because I may be compiling the code on a
> slightly older Linux box that doesn't have IFLA_WIRELESS defined.
> The only solution I have so far is to check whether the message
> contains the IFLA_IFNAME field, but this is more like a work-around
> rather than a solution. Any suggestions?

	The method I personally use is that I keep a little database
of interfaces (I need it for other reasons). Therefore, I know if the
interface is new (not in my database) or already exist (present in my
database).
	Note that in theory, RtNetlink messages may be lost (due to
memory pressure). Also, you won't only get NEWLINK when interface
register, but also when interface goes up and down, or when multicast
or promiscuous flags are changed. Which mean that in practice you want
to be much more clever than what you do now.

	Both methods you suggest would also work. If IFLA_WIRELESS
doesn't exist, just define it :
-----------------------------
#ifndef IFLA_WIRELESS
#define IFLA_WIRELESS	(IFLA_MASTER + 1)
#endif /* IFLA_WIRELESS */
-----------------------------

	The latest method is to look at both ifi_flags and
ifi_change. If ifi_change is 0, it is usually a wireless event (but
not always).

	Have fun...

	Jean

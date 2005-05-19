From: Jonathan Day <imipak@yahoo.com>
Subject: Re: igmp snooping?
Date: Wed, 18 May 2005 22:09:58 -0700 (PDT)
Message-ID: <20050519050958.86591.qmail@web31503.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>, hadi@cyberus.ca
In-Reply-To: 6667
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The information there is excellent, but I would add
one note of caution. IGMPv3 is extensible, and one of
the early extensions out there is for privacy and
security. (No big surprise, there.)

Unless you can guarantee that an IGMPv3 packet will
not contain any extensions not directly supported by
the underlying system, how much of the information you
can snoop on once the packet has been parsed by the
kernel is going to be implementation-dependent.

Now, in 99.99% of all cases, you're not going to have
any significant IGMPv3 traffic, as barely anyone uses
it yet and IGMP specifies that the highest common
version will be used in a group. Thus, if the group
contains IPMPv2 or even IGMPv1 members, none of what
I've written is the least bit important.

If all the systems are using the same OS, then it also
doesn't matter, as anything supported in one will be
supported in the others.

Any case that is left over is the case where you may
need to intercept the traffic prior to it being parsed
by the usual IGMP handler in the kernel. Even so,
you're still using a userspace application, you'd just
want to use one of the pseudo network devices to run a
copy of the traffic to your program.

So the direst case you could possibly imagine is
certainly very doable, and most cases are considerably
easier.

--- David Stevens <dlstevens@us.ibm.com> wrote:
> If you put the interface in multicast promiscuous
> mode (set flag 
> IFF_ALLMULTI),
> you can receive all hardware groups without joining.
> 
> For IGMP and MLD packets, one way to do that pat in
> an application is to 
> create
> a raw socket and specify the protocol there. So, to
> receive all reports
> for any version of IGMP sent to any group, you can
> create a socket like 
> this:
> 
>         s = socket(PF_INET, SOCK_RAW, IPPROTO_IGMP);
> 
> 
> For MLDv1 and MLDv2 (IPv6), they are part of ICMPv6,
> but you can use
> ICMPV6_FILTER with the MLD report types to receive
> only those.
> 
> You can get the receiving interface as ancillary
> data on a recvmsg()
> call with the IPV6_PKTINFO socket option on Linux
> systems
> (IPV6_RECVPKTINFO when RFC 3542 compliant) for IPv6
> and
> similarly with IP_PKTINFO with IPv4, I believe. You
> also can get this
> information by restricting the socket to receiving
> on a particular
> interface, if you don't want one socket to handle
> multiple interfaces.
> Then, you know which interface by which socket you
> received on.
> 
> So, you should be able to do most, possibly all, of
> what you want at
> application level without modification to the
> kernel, if you're looking
> to do this in an application and not a kernel
> module.
> 
>                                         +-DLS
> 
> 
> 


		
Discover Yahoo! 
Have fun online with music videos, cool games, IM and more. Check it out! 
http://discover.yahoo.com/online.html

From: Pavlin Radoslavov <pavlin@icir.org>
Subject: Re: NETLINK upcalls and wireless events
Date: Tue, 23 Mar 2004 21:43:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403240543.i2O5hdRj088576@possum.icir.org>
References: <gargid@cdacindia.com>
Cc: "'Pavlin Radoslavov'" <pavlin@icir.org>, hostap@shmoo.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Gargi D" <gargid@cdacindia.com>
In-Reply-To: Message from "Gargi D" <gargid@cdacindia.com>
   of "Wed, 24 Mar 2004 09:37:01 +0530." <001d01c41155$759ca8f0$1006a8c0@rahul>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I was wondering if you could help me in understanding the usage of
> netlink sockets.  Wireless events such as a signal that a new interface
> has been created, can anyway be read from 
> 
> /proc/net and var/lib/pcmcia/stab
> 
> Why would then want to use netlink sockets to get an indication of the
> same.

Just to clarify: I am not interested in wireless events, but when
a new network interface has appeared (regardless whether it is a
wireless interface or not).

There are several reasons I want to use netlink:
 * I am interest in much more events (new interface addresses,
    routes added/deleted/etc), and NETLINK is the natural mechanism
    to do all of that.
 * I am not sure that I can use asynchronously /proc/net/dev &
   friends to obtain interface-related events (but I may be wrong
   here).
   I am not familiar with var/lib/pcmcia/stab, but looks like it is
   pccard-specific, and I am interested in any type of interface.
 * I would prefer that I deal with system calls to obtain the
   information rather than parsing ASCII output.

Thanks,
Pavlin

> 
> 
> Regards, 
> 
> 
> Miss. Gargi Dadhich 
> Member Technical Staff 
> Networking and Internet Software Group (NISG) 
> C-DAC, Pune 
> 
> Tel:    020-25694000/1/2/3      Extn: 484 
> Fax:    020-25694059 
> 
> 
> 
> -----Original Message-----
> From: hostap-bounces+gargid=cdacindia.com@shmoo.com
> [mailto:hostap-bounces+gargid=cdacindia.com@shmoo.com] On Behalf Of
> Pavlin Radoslavov
> Sent: Tuesday, March 23, 2004 7:43 AM
> To: hostap@shmoo.com; netdev@oss.sgi.com
> Cc: pavlin@icir.org
> Subject: NETLINK upcalls and wireless events
> 
> 
> [Apology for the cross-post, but I am not sure which is the right
> mailing list for this question]
> 
> 
> BACKGROUND:
> 
> I am using Linux NETLINK sockets to monitor network interface events in
> the kernel such as "interface added/deleted", "address added/deleted",
> etc.
> 
> The RTM_NEWLINK message type upcall from the kernel to user-space is
> used to signal that a new network interface has been created (e.g., a
> tunnel interface, a PC-Card has been inserted, etc). One of the
> attributes of that message (see rtnetlink(7)) is IFLA_IFNAME and is used
> to store the device name (e.g., "tun0", "eth0", etc).
> 
> 
> PROBLEM:
> 
> So far everything worked fine on a desktop: whenever I add a tunnel, the
> kernel sends to user-space RTM_NEWLINK, I check the IFLA_IFNAME
> attribute to get the name of the new interface, etc.
> 
> However, a fellow tried same software on a laptop in wireless
> environment, and then RTM_NEWLINK messages started to appear for no
> apparent reason. Those messages did not contain the IFLA_IFNAME
> attribute which was strange and I started to suspect that it could be a
> kernel bug. After some investigation I found that the RTM_NEWLINK
> message can be generated not only when there is a new interface, but in
> some other cases as well. Inside file linux/wireless.h (I am looking
> into version 15 from 12.7.02) I found the following comment: 
> 
> /* ----------------------- WIRELESS EVENTS ----------------------- */
> /*
>  * Wireless events are carried through the rtnetlink socket to user
>  * space. They are encapsulated in the IFLA_WIRELESS field of
>  * a RTM_NEWLINK message.
>  */
> 
> 
> In other words, some wireless events may also generate RTM_NEWLINK
> message as well. I don't have a laptop with Linux to verify that myself,
> but I am quite sure that some wireless events do generate RTM_NEWLINK
> with no IFLA_IFNAME.
> 
> 
> QUESTION:
> 
> If I receive an RTM_NEWLINK message, is there a reliable way to find-out
> whether the message is generated because of a wireless event or because
> indeed there is a new network interface installed in the kernel.
> 
> Checking whether the message contains the IFLA_WIRELESS field is
> probably not an option, because I may be compiling the code on a
> slightly older Linux box that doesn't have IFLA_WIRELESS defined. The
> only solution I have so far is to check whether the message contains the
> IFLA_IFNAME field, but this is more like a work-around rather than a
> solution. Any suggestions?
> 
> Thanks,
> Pavlin
> _______________________________________________
> HostAP mailing list
> HostAP@shmoo.com
> http://lists.shmoo.com/mailman/listinfo/hostap
> 

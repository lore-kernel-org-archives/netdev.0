From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fw: F_SETSIG broken/changed in 2.6 for UDP and TCP sockets?
Date: Tue, 1 Jun 2004 14:19:04 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFAD1DE5B4.1A829EE7-ON88256EA6.006EE314-88256EA6.006F8B71@us.ibm.com>
References: <20040531151843.7144dfce.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, Russell Leighton <russ@elegant-software.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040531151843.7144dfce.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> In the udp case, I when I listen for multicast packets my app only
> receives them when I am running a tcpdump (bizarre!).

Russ,
        This piece (which I expect has nothing to do with the other
problems you mentioned) sounds like you haven't joined the groups on
the interface on which you're receiving the multicast packets.
"tcpdump" will place the interface in "promiscuous mode" which will
receive all packets, and ordinary packet delivery will allow
the application to receive them, even if you haven't joined the group
on the relevant interface.
        To verify if the group joins is broken, you can look at
/proc/net/igmp. If the groups you're joining are not listed on the
interface you want, the program isn't joining the groups correctly.
Group membership is per-interface, so joining a group on one interface
does not join it on another.
        Feel free to contact me if you need some help debugging the
multicast problem.

                                                        +-DLS

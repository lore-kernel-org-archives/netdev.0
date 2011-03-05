From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: bonding can't change to another slave if you ifdown the active
	slave
Date: Fri, 4 Mar 2011 21:53:32 -0500
Message-ID: <20110305025332.GR11864@gospo.rdu.redhat.com>
References: <4D704B35.20700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	Linda Wang <lwang@redhat.com>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049Ab1CECxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 21:53:43 -0500
Content-Disposition: inline
In-Reply-To: <4D704B35.20700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2011 at 10:15:17AM +0800, Weiping Pan wrote:
> Hi,
>
> I'm doing some Linux bonding driver test, and I find a problem in
> balance-rr mode.
> That's it can't change to another slave if you ifdown the active slave.
> Any comments are warmly welcomed!
>
> regards
> Weiping Pan
>
> My host is Fedora 14, and I install VirtualBox (4.0.2), and enable 4
> nics for the guest system.

Does this mean you are passing 4 NICs from your host to your guest
(maybe via direct pci-device assignment to the guest) or are you
creating 4 virtual devices on the host that are in a bridge group on the
host?

[...]
> [root@localhost ~]# ifconfig eth7 down

This is not a great way to test link failure with bonding.  The best way
is to actually pull the cable so the interface is truly down.

> [root@localhost ~]# dmesg
> [  304.496463] bonding: Ethernet Channel Bonding Driver: v3.6.0
> (September 26, 2009)
> [  304.496468] bonding: MII link monitoring set to 100 ms
> [  353.527680] ADDRCONF(NETDEV_UP): bond0: link is not ready
> [  355.321626] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: RX
> [  355.322250] bonding: bond0: enslaving eth7 as an active interface
> with an up link.
> [  355.323503] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
> [  365.394052] bond0: no IPv6 routers present
> [  510.913797] e1000: eth8 NIC Link is Up 1000 Mbps Full Duplex, Flow
> Control: RX
> [  510.917312] bonding: bond0: enslaving eth8 as an active interface
> with an up link.
> [  592.208534] bonding: bond0: link status definitely down for interface
> eth7, disabling it

I suspect I know, but what does /proc/net/bonding/bond0 look like?

[...]
> And meanwhile,
> [root@localhost ~]# tcpdump -i bond0 -p arp
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on bond0, link-type EN10MB (Ethernet), capture size 65535 bytes
> 02:46:56.983092 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:46:57.984040 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:46:58.988442 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:00.987340 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:01.988136 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:02.990033 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:04.985086 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:05.992368 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:06.996727 ARP, Request who-has 192.168.1.100 tell 192.168.1.5,
> length 28
> 02:47:17.231106 ARP, Request who-has dhcp-65-32.nay.redhat.com tell
> dhcp-65-180.nay.redhat.com, length 46
> ^C
> 10 packets captured
> 10 packets received by filter
> 0 packets dropped by kernel
>
>

What does a tcpdump on eth0 look like?  I'm curious if these arp
requests make it there or if the responses are the frames being dropped
(possibly by the connected bridge/switch).

From: David Lamparter <equinox@diac24.net>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Tue, 12 Jul 2011 02:02:42 +0200
Message-ID: <20110712000242.GA616804@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
 <20110711130729.607d461e@nehalam.ftrdhcpuser.net>
 <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
 <20110711134938.5178797c@nehalam.ftrdhcpuser.net>
 <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Lynn Hanson <LynnHanson@eaganhills.org>,
	Joe Whalen <JoeWhalen@eaganhills.org>
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:40776 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651Ab1GLACw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 20:02:52 -0400
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 04:08:14PM -0500, Greg Scott wrote:
> Uhmmmm - no it didn't.  Remember, I put br0 into promiscuous mode myself
> by hand - take a look at this.  Note eth0 and eth1 are not in
> promiscuous mode.  I wonder how it would behave if I put the physical
> devices into promiscuous mode and left br0 alone?  This I can easily
> test during off hours.  
> 
> [root@ehac-fw2011 gregs]# ip link show
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state
> DOWN qlen 1000
>     link/ether 00:0e:7f:2d:d0:6e brd ff:ff:ff:ff:ff:ff
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP qlen 1000
>     link/ether 00:03:47:3a:59:79 brd ff:ff:ff:ff:ff:ff
> 4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP qlen 1000
>     link/ether 00:0d:88:31:d8:24 brd ff:ff:ff:ff:ff:ff
> 5: br0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc prio
> state UNKNOWN
>     link/ether 00:03:47:3a:59:79 brd ff:ff:ff:ff:ff:ff
> [root@ehac-fw2011 gregs]#

All bridge port devices should really be in promiscuous mode; either
this is just not displayed or the code is broken somewhere. On my 2.6.38
port both "ip" and "ifconfig" correctly show the devices as PROMISC
without any userspace tool setting this, no idea if this changed
recently.


However, I must say that your bug report sounds more like a 
forwarding-back-to-source-device IP-level problem. If I understand
your setup correctly, you have:

(servers)
 |
 +--------[eth0 <-br0-> eth1]------- internet
 |
(clients)

and what isn't working is the firewall forwarding packets that it
received on eth0/br0 back out on eth0/br0 on the IP level including
NATting? Or did I misunderstand?


-David


P.S.: any reason why you are (a) not using proxyarp instead of the
bridge and (b) not using a VLAN to put those servers with public IPs
in? You have a bit of a Frankennet there :/


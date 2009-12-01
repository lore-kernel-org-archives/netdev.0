From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
	separate vlan from bond device
Date: Mon, 30 Nov 2009 20:21:46 -0500
Message-ID: <20091201012145.GH1639@gospo.rdu.redhat.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbZLABVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 20:21:41 -0500
Content-Disposition: inline
In-Reply-To: <29892.1259625638@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 04:00:38PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >This allows a bond device to specify an arp_ip_target as a host that is
> >not on the same vlan as the base bond device.  A configuration like
> >this, now works:
> >
> >1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
> >    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> >    inet 127.0.0.1/8 scope host lo
> >    inet6 ::1/128 scope host
> >       valid_lft forever preferred_lft forever
> >2: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000
> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000
> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >    inet6 fe80::213:21ff:febe:33e9/64 scope link
> >       valid_lft forever preferred_lft forever
> >9: bond0.100@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
> >    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
> >    inet 10.0.100.2/24 brd 10.0.100.255 scope global bond0.100
> >    inet6 fe80::213:21ff:febe:33e9/64 scope link
> >       valid_lft forever preferred_lft forever
> 
> 	I'm not quite clear here on exactly what it is that doesn't
> work.
> 
> 	Putting the arp_ip_target on a VLAN destination already works
> (and has for a long time); I just checked against a 2.6.32-rc to make
> sure I wasn't misremembering.
> 
> 	Perhaps there's some nuance of "not on the same vlan as the base
> bond device" that I'm missing.  What I see working before me is, e.g., a
> bond0.777 VLAN interface atop a regular bond0 active-backup with a
> couple of slaves; bond0 may or may not have an IP address of its own.
> The arp_ip_target destination is on VLAN 777 somewhere.

Do you have net.ipv4.conf.all.arp_ignore set to 0 and/or an IP address
assigned on bond0?  I can easily reproduce this with no IP on bond0 and
net.ipv4.conf.all.arp_ignore = 1.

I can't say for sure that the sysctl setting makes a difference, but I
have that on all my test rigs, so it's worth mentioning.

> 	Is this what your patch is meant to enable, or is it something
> different?  I'm pulling down today's net-next to see if this is
> something that broke recently.
> 

I first tested and found the problem while running 2.6.30-rc series
after it was reported to be a problem on RHEL5.  It's not clear how long
it has been broken, but this situation is odd enough that it probably
never worked as it was never tested.


From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: RTNL: assertion failed at net/core/dev.c (4494) and RTNL: assertion
 failed at net/core/rtnetlink.c (940)
Date: Thu, 6 Feb 2014 21:51:06 +0100
Message-ID: <20140206205106.GA10488@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([88.198.249.254]:58527 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbaBFU7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 15:59:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
this morning I checked out Linus tip and compiled it after booting my
dmesg is full of:

[    8.944991] RTNL: assertion failed at net/core/dev.c (4494)
[    8.950640] CPU: 3 PID: 388 Comm: kworker/u24:4 Not tainted 3.14.0-rc1+ #3
[    8.950642] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[    8.950654] Workqueue: bond0 bond_3ad_state_machine_handler [bonding]
[    8.950658]  0000000000000000 ffff881020c88000 ffffffff8138e219 ffff881020c88000
[    8.950664]  ffffffff812d3091 ffff881023961040 ffffffff812e3132 0000000000000246
[    8.950670]  0000000000000020 ffff881020ab1be8 0000000020ab1ba8 0000000000000000
[    8.950675] Call Trace:
[    8.950686]  [<ffffffff8138e219>] ? dump_stack+0x41/0x51
[    8.950694]  [<ffffffff812d3091>] ? netdev_master_upper_dev_get+0x2a/0x4d
[    8.950699]  [<ffffffff812e3132>] ? rtnl_fill_ifinfo+0x2c/0xac4
[    8.950707]  [<ffffffff81072211>] ? print_time.part.5+0x50/0x54
[    8.950715]  [<ffffffff812caf94>] ? __kmalloc_reserve.isra.42+0x2a/0x6d
[    8.950721]  [<ffffffff81102040>] ? ksize+0x12/0x1e
[    8.950726]  [<ffffffff812cb2b7>] ? __alloc_skb+0xb5/0x1a9
[    8.950731]  [<ffffffff812e4626>] ? rtmsg_ifinfo+0x6c/0xd6
[    8.950739]  [<ffffffffa035f4f9>] ? __enable_port.isra.17+0x51/0x5a [bonding]
[    8.950747]  [<ffffffffa0360463>] ? ad_agg_selection_logic+0x3d3/0x3ed [bonding]
[    8.950754]  [<ffffffffa0360d40>] ? bond_3ad_state_machine_handler+0x555/0x918 [bonding]
[    8.950761]  [<ffffffff8104db2d>] ? process_one_work+0x191/0x293
[    8.950766]  [<ffffffff8104dfde>] ? worker_thread+0x121/0x1e7
[    8.950770]  [<ffffffff8104debd>] ? rescuer_thread+0x269/0x269
[    8.950777]  [<ffffffff810527b6>] ? kthread+0x99/0xa1
[    8.950782]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59
[    8.950789]  [<ffffffff8139733c>] ? ret_from_fork+0x7c/0xb0
[    8.950794]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59
[    8.950797] RTNL: assertion failed at net/core/rtnetlink.c (940)
[    8.956863] CPU: 3 PID: 388 Comm: kworker/u24:4 Not tainted 3.14.0-rc1+ #3
[    8.956871] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
[    8.956877] Workqueue: bond0 bond_3ad_state_machine_handler [bonding]
[    8.956879]  0000000000000000 ffff881020c88000 ffffffff8138e219 ffff881023961040
[    8.956884]  ffffffff812e315e 0000000000000246 0000000000000020 ffff881020ab1be8
[    8.956890]  0000000020ab1ba8 0000000000000000 ffffffff817ef530 0000000000000008
[    8.956895] Call Trace:
[    8.956899]  [<ffffffff8138e219>] ? dump_stack+0x41/0x51
[    8.956903]  [<ffffffff812e315e>] ? rtnl_fill_ifinfo+0x58/0xac4
[    8.956909]  [<ffffffff81072211>] ? print_time.part.5+0x50/0x54
[    8.956915]  [<ffffffff812caf94>] ? __kmalloc_reserve.isra.42+0x2a/0x6d
[    8.956920]  [<ffffffff81102040>] ? ksize+0x12/0x1e
[    8.956925]  [<ffffffff812cb2b7>] ? __alloc_skb+0xb5/0x1a9
[    8.956929]  [<ffffffff812e4626>] ? rtmsg_ifinfo+0x6c/0xd6
[    8.956936]  [<ffffffffa035f4f9>] ? __enable_port.isra.17+0x51/0x5a [bonding]
[    8.956942]  [<ffffffffa0360463>] ? ad_agg_selection_logic+0x3d3/0x3ed [bonding]
[    8.956949]  [<ffffffffa0360d40>] ? bond_3ad_state_machine_handler+0x555/0x918 [bonding]
[    8.956954]  [<ffffffff8104db2d>] ? process_one_work+0x191/0x293
[    8.956958]  [<ffffffff8104dfde>] ? worker_thread+0x121/0x1e7
[    8.956962]  [<ffffffff8104debd>] ? rescuer_thread+0x269/0x269
[    8.956968]  [<ffffffff810527b6>] ? kthread+0x99/0xa1
[    8.956973]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59
[    8.956978]  [<ffffffff8139733c>] ? ret_from_fork+0x7c/0xb0
[    8.956983]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59

Full dmesg is at: http://pbot.rmdir.de/dJZsX0d71RFPaZAAjcTBWQ

I'm running Debian Wheezy and my Interface Konfiguration is:

auto lo
iface lo inet loopback

auto bond0
iface bond0 inet static
       address 10.100.4.62
       netmask 255.255.0.0
       gateway 10.100.0.1
       slaves eth0 eth1
       bond-mode 802.3ad
       bond-miimon 100

auto bond0.101
iface bond0.101 inet static
       address 10.101.99.4
       netmask 255.255.0.0

auto bond0.102
iface bond0.102 inet static
       address 10.102.99.4
       netmask 255.255.0.0

auto bond0.103
iface bond0.103 inet static
       address 10.103.99.4
       netmask 255.255.0.0

auto bond1
iface bond1 inet static
       address 10.100.5.62
       netmask 255.255.0.0
       slaves eth2 eth3
       bond-mode 802.3ad
       bond-miimon 100

auto bond1.101
iface bond1.101 inet static
       address 10.101.99.5
       netmask 255.255.0.0

auto bond1.102
iface bond1.102 inet static
       address 10.102.99.5
       netmask 255.255.0.0

auto bond1.103
iface bond1.103 inet static
       address 10.103.99.5
       netmask 255.255.0.0

My IPv4 interface Konfiguration is:

(node-62) [~/work/linux-2.6] ip -4 a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.100.4.62/16 brd 10.100.255.255 scope global bond0
       valid_lft forever preferred_lft forever
7: bond0.101@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.101.99.4/16 brd 10.101.255.255 scope global bond0.101
       valid_lft forever preferred_lft forever
8: bond0.102@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.102.99.4/16 brd 10.102.255.255 scope global bond0.102
       valid_lft forever preferred_lft forever
9: bond0.103@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.103.99.4/16 brd 10.103.255.255 scope global bond0.103
       valid_lft forever preferred_lft forever
10: bond1: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.100.5.62/16 brd 10.100.255.255 scope global bond1
       valid_lft forever preferred_lft forever
11: bond1.101@bond1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.101.99.5/16 brd 10.101.255.255 scope global bond1.101
       valid_lft forever preferred_lft forever
12: bond1.102@bond1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.102.99.5/16 brd 10.102.255.255 scope global bond1.102
       valid_lft forever preferred_lft forever
13: bond1.103@bond1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    inet 10.103.99.5/16 brd 10.103.255.255 scope global bond1.103
       valid_lft forever preferred_lft forever

I also have IPv6 with link-local and global addresses configured.

Kernel Config is at: http://pbot.rmdir.de/VTAnhVv8ECP7a7SPaxMsFA

I'm available for testing fixes or providing ssh access to the system if you
want to do further tests. I have the same config running on 3.13.0 on the same
machine without any problems whatsoever. If I should bisect it, let me know.

Cheers,
        Thomas

From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Fix panic in ip6_pol_route
Date: Wed, 06 Apr 2011 12:15:04 +0530
Message-ID: <20110406064504.30691.36599.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:39155 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab1DFGpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 02:45:09 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p366j7bS027129
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 16:45:07 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p366j77m1572872
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 16:45:07 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p366j61Y028912
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 16:45:06 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlan testing panic'd with this script:
	# vconfig add lo 42
	# vconfig rem lo.42
	# ifdown lo
	# ifup lo
	# ping6 fe80::%eth0
BUG: unable to handle kernel NULL pointer dereference at 0000000000000106
IP: [<ffffffffa018efd3>] ip6_pol_route+0x233/0x360 [ipv6]
PGD 1c1a8067 PUD 1cb2a067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/virtual/net/lo.42/addr_len
CPU 0 
Modules linked in: garp stp llc ip6table_filter ip6_tables iptable_filter
ip_tables ebtable_nat ebtables autofs4 sunrpc ipv6 virtio_net virtio_balloon
snd_intel8x0 snd_ac97_codec ac97_bus snd_seq snd_seq_device snd_pcm snd_timer
snd soundcore snd_page_alloc i2c_piix4 i2c_core sg ext3 jbd mbcache sd_mod
crc_t10dif virtio_pci virtio_ring virtio pata_acpi ata_generic ata_piix dm_mod
[last unloaded: 8021q]

Modules linked in: garp stp llc ip6table_filter ip6_tables iptable_filter
ip_tables ebtable_nat ebtables autofs4 sunrpc ipv6 virtio_net virtio_balloon
snd_intel8x0 snd_ac97_codec ac97_bus snd_seq snd_seq_device snd_pcm snd_timer
snd soundcore snd_page_alloc i2c_piix4 i2c_core sg ext3 jbd mbcache sd_mod
crc_t10dif virtio_pci virtio_ring virtio pata_acpi ata_generic ata_piix dm_mod
[last unloaded: 8021q]
Pid: 1752, comm: ping6 Not tainted 2.6.32-71.18.5.mcp7.x86_64 #1 Bochs
RIP: 0010:[<ffffffffa018efd3>]  [<ffffffffa018efd3>] ip6_pol_route+0x233/0x360
[ipv6]
RSP: 0018:ffff88001fad1ae8  EFLAGS: 00010296
RAX: ffff88001fb23800 RBX: ffff88001fb23800 RCX: ffff88001fb23800
RDX: ffffffff81c99600 RSI: 0000000000000002 RDI: ffff88001fb23800
RBP: ffff88001fad1b78 R08: 000000000000000b R09: ffff88001fb23910
R10: 0000000000000000 R11: ffff88001fad1da4 R12: 00000000ffffffff
R13: 0000000000000003 R14: 0000000000000002 R15: ffff88001fad1b44
FS:  00007f89ed64a700(0000) GS:ffff880001e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000106 CR3: 000000001cb1e000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ping6 (pid: 1752, threadinfo ffff88001fad0000, task ffff88001cadeaf0)
Stack:
 000000001cadeaf0 ffff88001fa84254 0000000100000003 ffff88001fa84258
<0> ffff88001fad1db4 ffff88001fad1da4 0000000200000002 ffffffff81c99600
<0> ffff88001fa84258 ffff88001fb23800 ffffea0000000041 ffffffff00000000
Call Trace:
 [<ffffffffa018f116>] ip6_pol_route_output+0x16/0x20 [ipv6]
 [<ffffffffa01b2601>] fib6_rule_action+0xd1/0x1f0 [ipv6]
 [<ffffffffa018f100>] ? ip6_pol_route_output+0x0/0x20 [ipv6]
 [<ffffffff8142205d>] fib_rules_lookup+0xbd/0x110
 [<ffffffffa01b2755>] fib6_rule_lookup+0x35/0xa0 [ipv6]
 [<ffffffffa018f100>] ? ip6_pol_route_output+0x0/0x20 [ipv6]
 [<ffffffffa018d2c5>] ip6_route_output+0xa5/0xc0 [ipv6]
 [<ffffffffa0180773>] ip6_dst_lookup_tail+0x223/0x250 [ipv6]
 [<ffffffffa0197b60>] ? ipv6_rcv_saddr_equal+0x0/0x1f0 [ipv6]
 [<ffffffffa01808b5>] ip6_dst_lookup+0x15/0x20 [ipv6]
 [<ffffffffa01ab493>] ip6_datagram_connect+0x323/0x630 [ipv6]
 [<ffffffff814c93cb>] ? _spin_unlock_bh+0x1b/0x20
 [<ffffffff813ff697>] ? release_sock+0xb7/0xd0
 [<ffffffff8146f5ec>] inet_dgram_connect+0x2c/0x80
 [<ffffffff813fd1c7>] sys_connect+0xd7/0xf0
 [<ffffffff810d3872>] ? audit_syscall_entry+0x272/0x2a0
 [<ffffffff81013172>] system_call_fastpath+0x16/0x1b
Code: 28 48 8b 4d b8 48 8b 55 a8 48 8b 41 18 48 8b 80 08 04 00 00 4c 8b 80 c0
03 00 00 48 8b 82 c0 03 00 00 4c 39 c0 0f 84 35 ff ff ff <41> f6 80 fb 00 00 00
01 0f 85 aa 00 00 00 3e 41 ff 80 c0 00 00 
RIP  [<ffffffffa018efd3>] ip6_pol_route+0x233/0x360 [ipv6]
 RSP <ffff88001fad1ae8>
CR2: 0000000000000106

The fix is to not update ip6_null_entry for a vlan device. Please
review.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/route.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -ruNp org/net/ipv6/route.c new/net/ipv6/route.c
--- org/net/ipv6/route.c	2011-03-29 19:35:21.000000000 +0530
+++ new/net/ipv6/route.c	2011-03-29 19:36:05.000000000 +0530
@@ -2488,7 +2488,8 @@ static int ip6_route_dev_notify(struct n
 	struct net_device *dev = (struct net_device *)data;
 	struct net *net = dev_net(dev);
 
-	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
+	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK) &&
+	    !(dev->priv_flags & IFF_802_1Q_VLAN)) {
 		net->ipv6.ip6_null_entry->dst.dev = dev;
 		net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES

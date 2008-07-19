From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/1] [TCP] fix kernel panic with listening_get_next
Date: Sat, 19 Jul 2008 08:31:58 +0200
Message-ID: <48818A5E.8030307@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090603080901070507060702"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:11036 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbYGSGcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 02:32:08 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6J6W5bH192444
	for <netdev@vger.kernel.org>; Sat, 19 Jul 2008 06:32:05 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6J6W5Lq2814136
	for <netdev@vger.kernel.org>; Sat, 19 Jul 2008 08:32:05 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6J6W4ad015003
	for <netdev@vger.kernel.org>; Sat, 19 Jul 2008 08:32:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090603080901070507060702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------090603080901070507060702
Content-Type: text/plain;
 name="fix-listening-get-next.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-listening-get-next.patch"

Subject: [TCP] fix kernel panic with listening_get_next
From: Daniel Lezcano <dlezcano@fr.ibm.com>

# BUG: unable to handle kernel NULL pointer dereference at
0000000000000038
IP: [<ffffffff821ed01e>] listening_get_next+0x50/0x1b3
PGD 11e4b9067 PUD 11d16c067 PMD 0
Oops: 0000 [1] SMP
last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
CPU 3
Modules linked in: bridge ipv6 button battery ac loop dm_mod tg3 ext3
jbd edd fan thermal processor thermal_sys hwmon sg sata_svw libata dock
serverworks sd_mod scsi_mod ide_disk ide_core [last unloaded: freq_table]
Pid: 3368, comm: slpd Not tainted 2.6.26-rc2-mm1-lxc4 #1
RIP: 0010:[<ffffffff821ed01e>] [<ffffffff821ed01e>]
listening_get_next+0x50/0x1b3
RSP: 0018:ffff81011e1fbe18 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8100be0ad3c0 RCX: ffff8100619f50c0
RDX: ffffffff82475be0 RSI: ffff81011d9ae6c0 RDI: ffff8100be0ad508
RBP: ffff81011f4f1240 R08: 00000000ffffffff R09: ffff8101185b6780
R10: 000000000000002d R11: ffffffff820fdbfa R12: ffff8100be0ad3c8
R13: ffff8100be0ad6a0 R14: ffff8100be0ad3c0 R15: ffffffff825b8ce0
FS: 00007f6a0ebd16d0(0000) GS:ffff81011f424540(0000)
knlGS:0000000000000000
CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000038 CR3: 000000011dc20000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process slpd (pid: 3368, threadinfo ffff81011e1fa000, task
ffff81011f4b8660)
Stack: 00000000000002ee ffff81011f5a57c0 ffff81011f4f1240
ffff81011e1fbe90
0000000000001000 0000000000000000 00007fff16bf2590 ffffffff821ed9c8
ffff81011f5a57c0 ffff81011d9ae6c0 000000000000041a ffffffff820b0abd
Call Trace:
[<ffffffff821ed9c8>] ? tcp_seq_next+0x34/0x7e
[<ffffffff820b0abd>] ? seq_read+0x1aa/0x29d
[<ffffffff820d21b4>] ? proc_reg_read+0x73/0x8e
[<ffffffff8209769c>] ? vfs_read+0xaa/0x152
[<ffffffff82097a7d>] ? sys_read+0x45/0x6e
[<ffffffff8200bd2b>] ? system_call_after_swapgs+0x7b/0x80


Code: 31 a9 25 00 e9 b5 00 00 00 ff 45 20 83 7d 0c 01 75 79 4c 8b 75 10
48 8b 0e eb 1d 48 8b 51 20 0f b7 45 08 39 02 75 0e 48 8b 41 28 <4c> 39
78 38 0f 84 93 00 00 00 48 8b 09 48 85 c9 75 de 8b 55 1c
RIP [<ffffffff821ed01e>] listening_get_next+0x50/0x1b3
RSP <ffff81011e1fbe18>
CR2: 0000000000000038

This kernel panic appears with CONFIG_NET_NS=y.

How to reproduce ?

    On the buggy host (host A)
       * ip addr add 1.2.3.4/24 dev eth0

    On a remote host (host B)
       * ip addr add 1.2.3.5/24 dev eth0
       * iptables -A INPUT -p tcp -s 1.2.3.4 -j DROP
       * ssh 1.2.3.4

    On host A:
       * netstat -ta or cat /proc/net/tcp

This bug happens when reading /proc/net/tcp[6] when there is a req_sock
at the SYN_RECV state.

When a SYN is received the minisock is created and the sk field is set to
NULL. In the listening_get_next function, we try to look at the field 
req->sk->sk_net.

When looking at how to fix this bug, I noticed that is useless to do
the check for the minisock belonging to the namespace. A minisock belongs
to a listen point and this one is per namespace, so when browsing the
minisock they are always per namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv4/tcp_ipv4.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: net-2.6/net/ipv4/tcp_ipv4.c
===================================================================
--- net-2.6.orig/net/ipv4/tcp_ipv4.c
+++ net-2.6/net/ipv4/tcp_ipv4.c
@@ -1862,8 +1862,7 @@ static void *listening_get_next(struct s
 		req = req->dl_next;
 		while (1) {
 			while (req) {
-				if (req->rsk_ops->family == st->family &&
-				    net_eq(sock_net(req->sk), net)) {
+				if (req->rsk_ops->family == st->family) {
 					cur = req;
 					goto out;
 				}

--------------090603080901070507060702--

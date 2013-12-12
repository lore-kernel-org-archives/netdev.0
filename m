From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] packet: fix using smp_processor_id() in preemptible code
Date: Thu, 12 Dec 2013 22:39:55 +0100
Message-ID: <1386884395-12449-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Li Zhong <zhong@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab3LLVkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 16:40:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zhong <zhong@linux.vnet.ibm.com>

This patches fixes the following warning by replacing smp_processor_id()
with raw_smp_processor_id():

[   11.120893] BUG: using smp_processor_id() in preemptible [00000000] code: arping/3510
[   11.120913] caller is .packet_sendmsg+0xc14/0xe68
[   11.120920] CPU: 13 PID: 3510 Comm: arping Not tainted 3.13.0-rc3-next-20131211-dirty #1
[   11.120926] Call Trace:
[   11.120932] [c0000001f803f6f0] [c0000000000138dc] .show_stack+0x110/0x25c (unreliable)
[   11.120942] [c0000001f803f7e0] [c00000000083dd24] .dump_stack+0xa0/0x37c
[   11.120951] [c0000001f803f870] [c000000000493fd4] .debug_smp_processor_id+0xfc/0x12c
[   11.120959] [c0000001f803f900] [c0000000007eba78] .packet_sendmsg+0xc14/0xe68
[   11.120968] [c0000001f803fa80] [c000000000700968] .sock_sendmsg+0xa0/0xe0
[   11.120975] [c0000001f803fbf0] [c0000000007014d8] .SyS_sendto+0x100/0x148
[   11.120983] [c0000001f803fd60] [c0000000006fff10] .SyS_socketcall+0x1c4/0x2e8
[   11.120990] [c0000001f803fe30] [c00000000000a1e4] syscall_exit+0x0/0x9c

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Just resending for Li with correct date.

 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9d70f13..cc803c6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -310,7 +310,7 @@ static bool packet_use_direct_xmit(const struct packet_sock *po)
 
 static u16 packet_pick_tx_queue(struct net_device *dev)
 {
-	return (u16) smp_processor_id() % dev->real_num_tx_queues;
+	return (u16) raw_smp_processor_id() % dev->real_num_tx_queues;
 }
 
 /* register_prot_hook must be invoked with the po->bind_lock held,
-- 
1.8.3.1

From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: [PATCH net-next] af_packet: use define instead of constant
Date: Mon, 20 Aug 2012 15:34:03 +0200
Message-ID: <1345469643.22726.2.camel@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53070 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617Ab2HTNeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 09:34:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a hard-coded value for the status variable, it would make
the code more readable to use its destined define from linux/if_packet.h.

Signed-off-by: daniel.borkmann@tik.ee.ethz.ch
---
 net/packet/af_packet.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 226b2cd..3ee372a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -855,7 +855,8 @@ static void prb_fill_vlan_info(struct tpacket_kbdq_core *pkc,
 		ppd->hv1.tp_vlan_tci = vlan_tx_tag_get(pkc->skb);
 		ppd->tp_status = TP_STATUS_VLAN_VALID;
 	} else {
-		ppd->hv1.tp_vlan_tci = ppd->tp_status = 0;
+		ppd->hv1.tp_vlan_tci = 0;
+		ppd->tp_status = TP_STATUS_AVAILABLE;
 	}
 }
 
@@ -1943,7 +1944,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	int tp_len, size_max;
 	unsigned char *addr;
 	int len_sum = 0;
-	int status = 0;
+	int status = TP_STATUS_AVAILABLE;
 	int hlen, tlen;
 
 	mutex_lock(&po->pg_vec_lock);

From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next v3 7/7] sk_buff.h: improve description of CHECKSUM_{COMPLETE,UNNECESSARY}
Date: Thu, 18 May 2017 15:44:43 +0200
Message-ID: <bc08ba316c518e04742a6bd22773ceb7f5c4e814.1495112302.git.dcaratti@redhat.com>
References: <cover.1495112301.git.dcaratti@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41174 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755367AbdERNpI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:45:08 -0400
In-Reply-To: <cover.1495112301.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add FCoE to the list of protocols that can set CHECKSUM_UNNECESSARY; add a
note to CHECKSUM_COMPLETE section to specify that it does not apply to SCTP
and FCoE protocols.

Suggested-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Acked-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 43d7ca07..1713e4b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -109,6 +109,7 @@
  *       may perform further validation in this case.
  *     GRE: only if the checksum is present in the header.
  *     SCTP: indicates the CRC in SCTP header has been validated.
+ *     FCOE: indicates the CRC in FC frame has been validated.
  *
  *   skb->csum_level indicates the number of consecutive checksums found in
  *   the packet minus one that have been verified as CHECKSUM_UNNECESSARY.
@@ -126,8 +127,10 @@
  *   packet as seen by netif_rx() and fills out in skb->csum. Meaning, the
  *   hardware doesn't need to parse L3/L4 headers to implement this.
  *
- *   Note: Even if device supports only some protocols, but is able to produce
- *   skb->csum, it MUST use CHECKSUM_COMPLETE, not CHECKSUM_UNNECESSARY.
+ *   Notes:
+ *   - Even if device supports only some protocols, but is able to produce
+ *     skb->csum, it MUST use CHECKSUM_COMPLETE, not CHECKSUM_UNNECESSARY.
+ *   - CHECKSUM_COMPLETE is not applicable to SCTP and FCoE protocols.
  *
  * CHECKSUM_PARTIAL:
  *
-- 
2.7.4

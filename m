From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v4 7/7] sk_buff.h: improve description of CHECKSUM_{COMPLETE,UNNECESSARY}
Date: Thu, 20 Apr 2017 15:38:13 +0200
Message-ID: <a6f87efa3d7a00deaaddd080cd41be8a5b34387e.1492692976.git.dcaratti@redhat.com>
References: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S945050AbdDTNjg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 09:39:36 -0400
In-Reply-To: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
In-Reply-To: <cover.1492692976.git.dcaratti@redhat.com>
References: <cover.1492692976.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add FCoE to the list of protocols that can set CHECKSUM_UNNECESSARY; add a
note to CHECKSUM_COMPLETE section to specify that it does not apply to SCTP
and FCoE protocols.

Suggested-by: Tom Herbert <tom@herbertland.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 include/linux/skbuff.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4002c11..c902b77 100644
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

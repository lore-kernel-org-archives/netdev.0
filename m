From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 10/20] net-sctp: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:15 -0700
Message-ID: <1302050665-10460-11-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
 <1302050665-10460-9-git-send-email-maheshb@google.com>
 <1302050665-10460-10-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:54005 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090Ab1DFAow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:52 -0400
In-Reply-To: <1302050665-10460-10-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/sctp/output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 60600d3..36efd46 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -501,7 +501,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
 	 */
 	if (!sctp_checksum_disable &&
-	    !(dst->dev->features & (NETIF_F_NO_CSUM | NETIF_F_SCTP_CSUM))) {
+	    !(dst->dev->legacy_features & (NETIF_F_NO_CSUM | NETIF_F_SCTP_CSUM))) {
 		__u32 crc32 = sctp_start_cksum((__u8 *)sh, cksum_buf_len);
 
 		/* 3) Put the resultant value into the checksum field in the
@@ -509,7 +509,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 		 */
 		sh->checksum = sctp_end_cksum(crc32);
 	} else {
-		if (dst->dev->features & NETIF_F_SCTP_CSUM) {
+		if (dst->dev->legacy_features & NETIF_F_SCTP_CSUM) {
 			/* no need to seed psuedo checksum for SCTP */
 			nskb->ip_summed = CHECKSUM_PARTIAL;
 			nskb->csum_start = (skb_transport_header(nskb) -
-- 
1.7.3.1


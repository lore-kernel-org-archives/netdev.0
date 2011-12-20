From: frank.blaschka@de.ibm.com
Subject: [patch 01/10] [PATCH] af_iucv: support ancillary data with HS transport
Date: Tue, 20 Dec 2011 09:56:27 +0100
Message-ID: <20111220085735.580688572@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:38200 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab1LTI56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:57:58 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:56 -0000
Content-Disposition: inline; filename=600-af_iucv-ancillary-hs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The AF_IUCV address family offers support for ancillary data.
This patch enables usage of ancillary data with the new
HiperSockets transport.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 net/iucv/af_iucv.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -2209,6 +2209,8 @@ static int afiucv_hs_rcv(struct sk_buff
 		break;
 	case 0:
 		/* plain data frame */
+		memcpy(CB_TRGCLS(skb), &trans_hdr->iucv_hdr.class,
+		       CB_TRGCLS_LEN);
 		err = afiucv_hs_callback_rx(sk, skb);
 		break;
 	default:

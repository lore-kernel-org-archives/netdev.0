From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/2] ppp: call skb_checksum_complete_unset in ppp_receive_frame
Date: Mon, 20 Apr 2015 14:10:05 -0700
Message-ID: <1429564205-1661247-3-git-send-email-tom@herbertland.com>
References: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:21859 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754471AbbDTVK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 17:10:28 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3KL2rlg002120
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:10:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1tw91cg0cj-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:10:28 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 aad26814e7a111e4aecf0002c9521c9e-b60a32c0 for <netdev@vger.kernel.org>;	Mon,
 20 Apr 2015 14:10:27 -0700
In-Reply-To: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call checksum_complete_unset in PPP receive to discard checksum-complete
value. PPP does not pull checksum for headers and also modifies packet
as in VJ compression.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ppp/ppp_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index af034db..9d15566 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1716,6 +1716,7 @@ ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 {
 	/* note: a 0-length skb is used as an error indication */
 	if (skb->len > 0) {
+		skb_checksum_complete_unset(skb);
 #ifdef CONFIG_PPP_MULTILINK
 		/* XXX do channel-level decompression here */
 		if (PPP_PROTO(skb) == PPP_MP)
-- 
1.8.1

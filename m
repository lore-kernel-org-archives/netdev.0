From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] flow_dissector: Fix MPLS entropy label handling in flow dissector
Date: Fri, 12 Jun 2015 09:01:05 -0700
Message-ID: <1434124866-3881537-2-git-send-email-tom@herbertland.com>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:24795 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751700AbbFLQB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 12:01:27 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5CFxgqf013359
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:01:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1v01n586t6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:01:26 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 4678d476111c11e5b9510002c991e86a-efe6e6e0 for <netdev@vger.kernel.org>;	Fri,
 12 Jun 2015 09:01:24 -0700
In-Reply-To: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to shift after masking to get label value for comparison.

Fixes: b3baa0fbd02a1a9d493d8 ("mpls: Add MPLS entropy label in flow_keys")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 77e22e4..1818cdc 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -299,8 +299,8 @@ mpls:
 		if (!hdr)
 			return false;
 
-		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) ==
-		     MPLS_LABEL_ENTROPY) {
+		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
+		     MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
 			if (skb_flow_dissector_uses_key(flow_dissector,
 							FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {
 				key_keyid = skb_flow_dissector_target(flow_dissector,
-- 
1.8.1

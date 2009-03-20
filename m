From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] Phonet:fix build problem
Date: Fri, 20 Mar 2009 14:58:38 +0300
Message-ID: <20090320115838.GA26371@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:46151 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbZCTL6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 07:58:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/phonet/pep.c: In function 'pipe_rcv_status':
net/phonet/pep.c:262: error: lvalue required as left operand of assignment

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 net/phonet/pep.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 8ad2b53..9a1aefa 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -259,7 +259,8 @@ static int pipe_rcv_status(struct sock *sk, struct sk_buff *skb)
 	case PN_PEP_IND_ID_MCFC_GRANT_CREDITS:
 		if (pn->tx_fc != PN_MULTI_CREDIT_FLOW_CONTROL)
 			break;
-		atomic_add(wake = hdr->data[4], &pn->tx_credits);
+		wake = hdr->data[4];
+		atomic_add(wake, &pn->tx_credits);
 		break;
 
 	default:

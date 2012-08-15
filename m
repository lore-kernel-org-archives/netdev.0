From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 11/14] dccp: check ccid before dereferencing
Date: Wed, 15 Aug 2012 23:31:54 +0200
Message-ID: <1345066317-22512-12-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ccid_hc_rx_getsockopt() and ccid_hc_tx_getsockopt() might be called with
a NULL ccid pointer leading to a NULL pointer dereference. This could
lead to a privilege escalation if the attacker is able to map page 0 and
prepare it with a fake ccid_ops pointer.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Cc: stable@vger.kernel.org
---
 net/dccp/ccid.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index 75c3582..fb85d37 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -246,7 +246,7 @@ static inline int ccid_hc_rx_getsockopt(struct ccid *ccid, struct sock *sk,
 					u32 __user *optval, int __user *optlen)
 {
 	int rc = -ENOPROTOOPT;
-	if (ccid->ccid_ops->ccid_hc_rx_getsockopt != NULL)
+	if (ccid != NULL && ccid->ccid_ops->ccid_hc_rx_getsockopt != NULL)
 		rc = ccid->ccid_ops->ccid_hc_rx_getsockopt(sk, optname, len,
 						 optval, optlen);
 	return rc;
@@ -257,7 +257,7 @@ static inline int ccid_hc_tx_getsockopt(struct ccid *ccid, struct sock *sk,
 					u32 __user *optval, int __user *optlen)
 {
 	int rc = -ENOPROTOOPT;
-	if (ccid->ccid_ops->ccid_hc_tx_getsockopt != NULL)
+	if (ccid != NULL && ccid->ccid_ops->ccid_hc_tx_getsockopt != NULL)
 		rc = ccid->ccid_ops->ccid_hc_tx_getsockopt(sk, optname, len,
 						 optval, optlen);
 	return rc;
-- 
1.7.10.4

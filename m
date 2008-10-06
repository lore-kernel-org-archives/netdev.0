From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH v7 08/17] smack: Fix missing calls to netlbl_skbuff_err()
Date: Mon, 06 Oct 2008 15:20:36 -0400
Message-ID: <20081006192036.15686.32534.stgit@flek.lan>
References: <20081006191516.15686.80823.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:15452 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbYJFTUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 15:20:40 -0400
In-Reply-To: <20081006191516.15686.80823.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smack needs to call netlbl_skbuff_err() to let NetLabel do the necessary
protocol specific error handling.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Acked-by: Casey Schaufler <casey@schaufler-ca.com>
---

 security/smack/smack_lsm.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 87d7541..6e2dc0b 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -2179,7 +2179,10 @@ static int smack_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 * This is the simplist possible security model
 	 * for networking.
 	 */
-	return smk_access(smack, ssp->smk_in, MAY_WRITE);
+	rc = smk_access(smack, ssp->smk_in, MAY_WRITE);
+	if (rc != 0)
+		netlbl_skbuff_err(skb, rc, 0);
+	return rc;
 }
 
 /**


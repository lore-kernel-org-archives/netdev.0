From: "Maxin B. John" <maxin.john@gmail.com>
Subject: [PATCH] net: scm: moving dereference after NULL check
Date: Sun, 23 Sep 2012 13:03:30 -0400
Message-ID: <20120923170330.GA5038@linux-3ix0.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catherine Zhang <cxzhang@watson.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

scm_destroy_cred() dereferences 'scm' before null check

Signed-off-by: Maxin B. John <maxin.john@gmail.com>
---
diff --git a/include/net/scm.h b/include/net/scm.h
index 7dc0854..ed25aa1 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -64,9 +64,11 @@ static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
 
 static __inline__ void scm_destroy(struct scm_cookie *scm)
 {
-	scm_destroy_cred(scm);
-	if (scm && scm->fp)
-		__scm_destroy(scm);
+	if (scm) {
+		scm_destroy_cred(scm);
+		if (scm->fp)
+			__scm_destroy(scm);
+	}
 }
 
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,

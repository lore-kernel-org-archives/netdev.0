From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/irda: add missing error path release_sock call
Date: Wed, 20 Mar 2013 08:19:24 -0700
Message-ID: <20130320151924.GA4955@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Brad Spengler <spender@grsecurity.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes sure that release_sock is called for all error conditions in
irda_getsockopt.

Signed-off-by: Kees Cook <keescook@chromium.org>
Reported-by: Brad Spengler <spender@grsecurity.net>
Cc: stable@vger.kernel.org
---
 net/irda/af_irda.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index d07e3a6..d28e7f0 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2583,8 +2583,10 @@ bed:
 				    NULL, NULL, NULL);
 
 		/* Check if the we got some results */
-		if (!self->cachedaddr)
-			return -EAGAIN;		/* Didn't find any devices */
+		if (!self->cachedaddr) {
+			err = -EAGAIN;		/* Didn't find any devices */
+			goto out;
+		}
 		daddr = self->cachedaddr;
 		/* Cleanup */
 		self->cachedaddr = 0;
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security

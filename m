From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH net-next 1/1] net: ppp: access ppp->nextseq only if CONFIG_PPP_MULTILINK
 is defined
Date: Wed, 16 Jul 2014 23:41:26 +0200
Message-ID: <53C6F186.30809@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Schulz <develop@kristov.de>

Commit d762d038497c9df51c19fcbe69b094b3bf8e5568 resets the counter holding the
next sequence number for multilink PPP fragments to zero whenever the
SC_MULTILINK flag is set. However, this counter only exists if
CONFIG_PPP_MULTILINK is defined. Consequently, the new code has to be enclosed
within #ifdef CONFIG_PPP_MULTILINK ... #endif.

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index c38ee90..458be47 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -661,8 +661,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			break;
 		ppp_lock(ppp);
 		cflags = ppp->flags & ~val;
+#ifdef CONFIG_PPP_MULTILINK
 		if (!(ppp->flags & SC_MULTILINK) && (val & SC_MULTILINK))
 			ppp->nextseq = 0;
+#endif
 		ppp->flags = val & SC_FLAG_BITS;
 		ppp_unlock(ppp);
 		if (cflags & SC_CCP_OPEN)

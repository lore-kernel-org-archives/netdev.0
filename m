From: Joe Perches <joe@perches.com>
Subject: [PATCH -next] device.h: Add missing inline to #ifndef CONFIG_PRINTK
 dev_vprintk_emit
Date: Tue, 25 Sep 2012 18:19:57 -0700
Message-ID: <1348622397.2648.13.camel@joe-AO722>
References: <cover.1345978012.git.joe@perches.com>
	 <7cfb202968f0928bba66965146a828a1cff87950.1345978012.git.joe@perches.com>
	 <CAMuHMdVH-ni1NhbTDXgh82WUSAV85fahUjp1BoizVy6D2Xyvaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@redhat.com>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54936 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753007Ab2IZBUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 21:20:01 -0400
In-Reply-To: <CAMuHMdVH-ni1NhbTDXgh82WUSAV85fahUjp1BoizVy6D2Xyvaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also add __printf() verification for format string.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Joe Perches <joe@perches.com>

---

 include/linux/device.h |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/device.h b/include/linux/device.h
index 8873603..86ef6ab 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -902,8 +902,9 @@ extern const char *dev_driver_string(const struct device *dev);
 
 #ifdef CONFIG_PRINTK
 
-extern int dev_vprintk_emit(int level, const struct device *dev,
-			    const char *fmt, va_list args);
+extern __printf(3, 0)
+int dev_vprintk_emit(int level, const struct device *dev,
+		     const char *fmt, va_list args);
 extern __printf(3, 4)
 int dev_printk_emit(int level, const struct device *dev, const char *fmt, ...);
 
@@ -927,8 +928,9 @@ int _dev_info(const struct device *dev, const char *fmt, ...);
 
 #else
 
-static int dev_vprintk_emit(int level, const struct device *dev,
-			    const char *fmt, va_list args)
+static inline __printf(3, 0)
+int dev_vprintk_emit(int level, const struct device *dev,
+		     const char *fmt, va_list args)
 { return 0; }
 static inline __printf(3, 4)
 int dev_printk_emit(int level, const struct device *dev, const char *fmt, ...)

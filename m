From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] nfc: Remove unused nfc_printk and nfc_<level> macros
Date: Tue, 29 Nov 2011 11:37:34 -0800
Message-ID: <759af9f0fd066ef1dcf7ad928940f68883d2ff13.1322595343.git.joe@perches.com>
References: <cover.1322595343.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1322595343.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All uses have been removed, so killing what's not necessary.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/nfc/core.c |   19 -------------------
 net/nfc/nfc.h  |    7 -------
 2 files changed, 0 insertions(+), 26 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index c922adb..3ebc6b3aa 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -35,25 +35,6 @@
 int nfc_devlist_generation;
 DEFINE_MUTEX(nfc_devlist_mutex);
 
-int nfc_printk(const char *level, const char *format, ...)
-{
-	struct va_format vaf;
-	va_list args;
-	int r;
-
-	va_start(args, format);
-
-	vaf.fmt = format;
-	vaf.va = &args;
-
-	r = printk("%sNFC: %pV\n", level, &vaf);
-
-	va_end(args);
-
-	return r;
-}
-EXPORT_SYMBOL(nfc_printk);
-
 /**
  * nfc_dev_up - turn on the NFC device
  *
diff --git a/net/nfc/nfc.h b/net/nfc/nfc.h
index d86583f..67d6050 100644
--- a/net/nfc/nfc.h
+++ b/net/nfc/nfc.h
@@ -27,13 +27,6 @@
 #include <net/nfc/nfc.h>
 #include <net/sock.h>
 
-__printf(2, 3)
-int nfc_printk(const char *level, const char *fmt, ...);
-
-#define nfc_info(fmt, arg...) nfc_printk(KERN_INFO, fmt, ##arg)
-#define nfc_err(fmt, arg...) nfc_printk(KERN_ERR, fmt, ##arg)
-#define nfc_dbg(fmt, arg...) pr_debug(fmt "\n", ##arg)
-
 struct nfc_protocol {
 	int id;
 	struct proto *proto;
-- 
1.7.6.405.gc1be0

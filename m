From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 15/19] sunrpc: don't warn for unused variable 'buf'
Date: Fri, 25 Jan 2013 14:14:32 +0000
Message-ID: <1359123276-15833-16-git-send-email-arnd@arndb.de>
References: <1359123276-15833-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: linux-arm-kernel@list.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359123276-15833-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When RPC_DEBUG is unset, the dprintk() macro does nothing,
causing the 'buf' variable in svc_printk to become unused.
Marking it as __maybe_unused avoids a harmless gcc warning.

Without this patch, building at91_dt_defconfig results in:

net/sunrpc/svc.c: In function 'svc_printk':
net/sunrpc/svc.c:1051:7: warning: unused variable 'buf' [-Wunused-variable]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sunrpc/svc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dbf12ac..b1f5223 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1047,7 +1047,7 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	char 	buf[RPC_MAX_ADDRBUFLEN];
+	char buf[RPC_MAX_ADDRBUFLEN] __maybe_unused;
 
 	va_start(args, fmt);
 
-- 
1.8.0

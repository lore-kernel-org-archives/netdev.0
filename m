From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] cfg80211: don't print log output for building shipped-certs
Date: Fri, 13 Oct 2017 14:04:30 +0200
Message-ID: <20171013120446.4079666-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building an allmodconfig kernel with 'make -s' now prints a single line:

  GEN     net/wireless/shipped-certs.c

Using '$(kecho)' here will skip the output with 'make -s' but
otherwise keeps printing it, which is consistent with how we
handle all the other output.

Fixes: 90a53e4432b1 ("cfg80211: implement regdb signature checking")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/wireless/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/wireless/Makefile b/net/wireless/Makefile
index 219baea57e4e..e585f3f71f77 100644
--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -23,7 +23,7 @@ cfg80211-y += extra-certs.o
 endif
 
 $(obj)/shipped-certs.c: $(wildcard $(srctree)/$(src)/certs/*.x509)
-	@echo "  GEN     $@"
+	@$(kecho) "  GEN     $@"
 	@echo '#include "reg.h"' > $@
 	@echo 'const u8 shipped_regdb_certs[] = {' >> $@
 	@for f in $^ ; do hexdump -v -e '1/1 "0x%.2x," "\n"' < $$f >> $@ ; done
@@ -32,7 +32,7 @@ $(obj)/shipped-certs.c: $(wildcard $(srctree)/$(src)/certs/*.x509)
 
 $(obj)/extra-certs.c: $(CONFIG_CFG80211_EXTRA_REGDB_KEYDIR:"%"=%) \
 		      $(wildcard $(CONFIG_CFG80211_EXTRA_REGDB_KEYDIR:"%"=%)/*.x509)
-	@echo "  GEN     $@"
+	@$(kecho) "  GEN     $@"
 	@echo '#include "reg.h"' > $@
 	@echo 'const u8 extra_regdb_certs[] = {' >> $@
 	@for f in $^ ; do test -f $$f && hexdump -v -e '1/1 "0x%.2x," "\n"' < $$f >> $@ || true ; done
-- 
2.9.0

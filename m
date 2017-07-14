From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 01/22] kbuild: disable -Wformat-truncation warnings by default
Date: Fri, 14 Jul 2017 14:06:53 +0200
Message-ID: <20170714120720.906842-2-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>, linux-kbuild@vger.kernel.org
To: linux-kernel@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With x86 allmodconfig, we currently get 233 -Wformat-truncation warnings,
which makes the entire warnings rather useless.

This turns off the warning by default, unless we specify W=1 or higher

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 scripts/Makefile.extrawarn | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/scripts/Makefile.extrawarn b/scripts/Makefile.extrawarn
index fb3522fd8702..4b63c2f71adb 100644
--- a/scripts/Makefile.extrawarn
+++ b/scripts/Makefile.extrawarn
@@ -67,5 +67,8 @@ KBUILD_CFLAGS += $(call cc-disable-warning, format)
 KBUILD_CFLAGS += $(call cc-disable-warning, sign-compare)
 KBUILD_CFLAGS += $(call cc-disable-warning, format-zero-length)
 KBUILD_CFLAGS += $(call cc-disable-warning, uninitialized)
+else
+# noisy gcc-7 warnings
+KBUILD_CFLAGS += $(call cc-option,-Wformat-truncation=0)
 endif
 endif
-- 
2.9.0

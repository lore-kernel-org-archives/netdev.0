From: Stephen Rothwell <Stephen@Rothwell.id.au>
Subject: linux-next: net tree build failure
Date: Mon, 11 Jan 2010 18:42:05 +1100
Message-ID: <20100111184205.8d53fe5b.Stephen@Rothwell.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next build (powerpc_allnoconfig) failed like this:

lib/lib.a(vsprintf.o): In function `pointer':
vsprintf.c:(.text+0x21ba): undefined reference to `byte_rev_table'
vsprintf.c:(.text+0x21c2): undefined reference to `byte_rev_table'

Caused by commit bc7259a2ce764ea16200eb9e53f6e136e918d065
("lib/vsprintf.c: Add %pMF to format FDDI bit reversed MAC addresses")
from the net tree.

I applied the following fixup patch (and can carry it for a while):
(BTW after this patch, CONFIG_BITREVERSE appears to not be used anywhere
except where is is selected in Kconfig files.)

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 11 Jan 2010 18:37:16 +1100
Subject: [PATCH] net: vsprintf now depends on the byte_rev_table

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 lib/Makefile |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/Makefile b/lib/Makefile
index 4b78894..e21f9f9 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -7,7 +7,7 @@ ORIG_CFLAGS := $(KBUILD_CFLAGS)
 KBUILD_CFLAGS = $(subst -pg,,$(ORIG_CFLAGS))
 endif
 
-lib-y := ctype.o string.o vsprintf.o cmdline.o \
+lib-y := ctype.o string.o vsprintf.o cmdline.o bitrev.o \
 	 rbtree.o radix-tree.o dump_stack.o \
 	 idr.o int_sqrt.o extable.o prio_tree.o \
 	 sha1.o irq_regs.o reciprocal_div.o argv_split.o \
@@ -50,7 +50,6 @@ ifneq ($(CONFIG_HAVE_DEC_LOCK),y)
   lib-y += dec_and_lock.o
 endif
 
-obj-$(CONFIG_BITREVERSE) += bitrev.o
 obj-$(CONFIG_RATIONAL)	+= rational.o
 obj-$(CONFIG_CRC_CCITT)	+= crc-ccitt.o
 obj-$(CONFIG_CRC16)	+= crc16.o
-- 
1.6.5.7


-- 
Cheers,
Stephen Rothwell                    Stephen@Rothwell.id.au

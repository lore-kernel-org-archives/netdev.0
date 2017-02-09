From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/12] bitfield.h: add FIELD_FIT() helper
Date: Thu,  9 Feb 2017 09:17:27 -0800
Message-ID: <20170209171738.17386-2-jakub.kicinski@netronome.com>
References: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35049 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753227AbdBIR0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:26:21 -0500
Received: by mail-pg0-f51.google.com with SMTP id 194so2306967pgd.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:26:21 -0800 (PST)
In-Reply-To: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper for checking at runtime that a value will fit inside
a specified field/mask.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h |  2 --
 include/linux/bitfield.h                     | 13 +++++++++++++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index 76a19f1796af..9513c80f7be5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -39,8 +39,6 @@
 #include <linux/list.h>
 #include <linux/types.h>
 
-#define FIELD_FIT(mask, val)  (!((((u64)val) << __bf_shf(mask)) & ~(mask)))
-
 /* For branch fixup logic use up-most byte of branch instruction as scratch
  * area.  Remember to clear this before sending instructions to HW!
  */
diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
index f6505d83069d..8b9d6fff002d 100644
--- a/include/linux/bitfield.h
+++ b/include/linux/bitfield.h
@@ -63,6 +63,19 @@
 	})
 
 /**
+ * FIELD_FIT() - check if value fits in the field
+ * @_mask: shifted mask defining the field's length and position
+ * @_val:  value to test against the field
+ *
+ * Return: true if @_val can fit inside @_mask, false if @_val is too big.
+ */
+#define FIELD_FIT(_mask, _val)						\
+	({								\
+		__BF_FIELD_CHECK(_mask, 0ULL, _val, "FIELD_FIT: ");	\
+		!((((typeof(_mask))_val) << __bf_shf(_mask)) & ~(_mask)); \
+	})
+
+/**
  * FIELD_PREP() - prepare a bitfield element
  * @_mask: shifted mask defining the field's length and position
  * @_val:  value to put in the field
-- 
2.11.0

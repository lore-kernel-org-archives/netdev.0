From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 01/19] byteorder: Move {cpu_to_be32,be32_to_cpu}_array() from Thunderbolt to core
Date: Mon,  2 Oct 2017 13:38:28 +0300
Message-ID: <20171002103846.64602-2-mika.westerberg@linux.intel.com>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will be using these when communicating XDomain discovery protocol
over Thunderbolt link but they might be useful for other drivers as
well.

Make them available through byteorder/generic.h.

Suggested-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/thunderbolt/ctl.c         | 14 --------------
 include/linux/byteorder/generic.h | 16 ++++++++++++++++
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/thunderbolt/ctl.c b/drivers/thunderbolt/ctl.c
index fb40dd0588b9..e6a4c9458c76 100644
--- a/drivers/thunderbolt/ctl.c
+++ b/drivers/thunderbolt/ctl.c
@@ -289,20 +289,6 @@ static void tb_cfg_print_error(struct tb_ctl *ctl,
 	}
 }
 
-static void cpu_to_be32_array(__be32 *dst, const u32 *src, size_t len)
-{
-	int i;
-	for (i = 0; i < len; i++)
-		dst[i] = cpu_to_be32(src[i]);
-}
-
-static void be32_to_cpu_array(u32 *dst, __be32 *src, size_t len)
-{
-	int i;
-	for (i = 0; i < len; i++)
-		dst[i] = be32_to_cpu(src[i]);
-}
-
 static __be32 tb_crc(const void *data, size_t len)
 {
 	return cpu_to_be32(~__crc32c_le(~0, data, len));
diff --git a/include/linux/byteorder/generic.h b/include/linux/byteorder/generic.h
index 89f67c1c3160..805d16654459 100644
--- a/include/linux/byteorder/generic.h
+++ b/include/linux/byteorder/generic.h
@@ -170,4 +170,20 @@ static inline void be64_add_cpu(__be64 *var, u64 val)
 	*var = cpu_to_be64(be64_to_cpu(*var) + val);
 }
 
+static inline void cpu_to_be32_array(__be32 *dst, const u32 *src, size_t len)
+{
+	int i;
+
+	for (i = 0; i < len; i++)
+		dst[i] = cpu_to_be32(src[i]);
+}
+
+static inline void be32_to_cpu_array(u32 *dst, const __be32 *src, size_t len)
+{
+	int i;
+
+	for (i = 0; i < len; i++)
+		dst[i] = be32_to_cpu(src[i]);
+}
+
 #endif /* _LINUX_BYTEORDER_GENERIC_H */
-- 
2.14.2

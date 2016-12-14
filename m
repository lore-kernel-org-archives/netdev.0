From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v2 2/4] siphash: add convenience functions for jhash converts
Date: Wed, 14 Dec 2016 04:59:25 +0100
Message-ID: <20161214035927.30004-2-Jason@zx2c4.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	kernel-hardening@lists.openwall.com,
	LKML <linux-kernel@vger.kernel.org>,
	linux-crypto@vger.kernel.org
Return-path: <kernel-hardening-return-5505-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161214035927.30004-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Many jhash users currently rely on the Nwords functions. In order to
make transitions to siphash fit something people already know about, we
provide analog functions here. This also winds up being nice for the
networking stack, where hashing 32-bit fields is common.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
Changes from v1->v2:

  - None in this patch, but see elsewhere in series.

 include/linux/siphash.h | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/include/linux/siphash.h b/include/linux/siphash.h
index 6623b3090645..1391054c4c29 100644
--- a/include/linux/siphash.h
+++ b/include/linux/siphash.h
@@ -17,4 +17,37 @@ enum siphash_lengths {
 
 u64 siphash24(const u8 *data, size_t len, const u8 key[SIPHASH24_KEY_LEN]);
 
+static inline u64 siphash24_1word(const u32 a, const u8 key[SIPHASH24_KEY_LEN])
+{
+	return siphash24((u8 *)&a, sizeof(a), key);
+}
+
+static inline u64 siphash24_2words(const u32 a, const u32 b, const u8 key[SIPHASH24_KEY_LEN])
+{
+	const struct {
+		u32 a;
+		u32 b;
+	} __packed combined = {
+		.a = a,
+		.b = b
+	};
+
+	return siphash24((const u8 *)&combined, sizeof(combined), key);
+}
+
+static inline u64 siphash24_3words(const u32 a, const u32 b, const u32 c, const u8 key[SIPHASH24_KEY_LEN])
+{
+	const struct {
+		u32 a;
+		u32 b;
+		u32 c;
+	} __packed combined = {
+		.a = a,
+		.b = b,
+		.c = c
+	};
+
+	return siphash24((const u8 *)&combined, sizeof(combined), key);
+}
+
 #endif /* _LINUX_SIPHASH_H */
-- 
2.11.0

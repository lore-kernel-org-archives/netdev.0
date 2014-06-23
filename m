From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] lib: crc32: Add some additional __pure annotations
Date: Mon, 23 Jun 2014 15:11:56 +0200
Message-ID: <1403529116-18385-4-git-send-email-dborkman@redhat.com>
References: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux@horizon.com,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Spelvin <linux@horizon.com>

In case they help the compiler.

Signed-off-by: George Spelvin <linux@horizon.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/crc32.h | 6 +++---
 lib/crc32.c           | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/crc32.h b/include/linux/crc32.h
index edf34e8..9e8a032 100644
--- a/include/linux/crc32.h
+++ b/include/linux/crc32.h
@@ -8,8 +8,8 @@
 #include <linux/types.h>
 #include <linux/bitrev.h>
 
-extern u32  crc32_le(u32 crc, unsigned char const *p, size_t len);
-extern u32  crc32_be(u32 crc, unsigned char const *p, size_t len);
+u32 __pure crc32_le(u32 crc, unsigned char const *p, size_t len);
+u32 __pure crc32_be(u32 crc, unsigned char const *p, size_t len);
 
 /**
  * crc32_le_combine - Combine two crc32 check values into one. For two
@@ -36,7 +36,7 @@ static inline u32 crc32_le_combine(u32 crc1, u32 crc2, size_t len2)
 	return crc32_le_shift(crc1, len2) ^ crc2;
 }
 
-extern u32  __crc32c_le(u32 crc, unsigned char const *p, size_t len);
+u32 __pure __crc32c_le(u32 crc, unsigned char const *p, size_t len);
 
 /**
  * __crc32c_le_combine - Combine two crc32c check values into one. For two
diff --git a/lib/crc32.c b/lib/crc32.c
index af938ab..9a907d4 100644
--- a/lib/crc32.c
+++ b/lib/crc32.c
@@ -53,7 +53,7 @@ MODULE_LICENSE("GPL");
 #if CRC_LE_BITS > 8 || CRC_BE_BITS > 8
 
 /* implements slicing-by-4 or slicing-by-8 algorithm */
-static inline u32
+static inline u32 __pure
 crc32_body(u32 crc, unsigned char const *buf, size_t len, const u32 (*tab)[256])
 {
 # ifdef __LITTLE_ENDIAN
-- 
1.7.11.7

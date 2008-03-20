From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] kernel: add byteorder function with alignment fixups
Date: Thu, 20 Mar 2008 12:41:27 -0700
Message-ID: <1206042087.17059.15.camel@brick>
References: <1206034454.17059.4.camel@brick>
	 <20080320182911.GQ10722@ZenIV.linux.org.uk>
	 <1206038244.17059.7.camel@brick>
	 <20080320190953.GR10722@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757522AbYCTTlq@vger.kernel.org>
In-Reply-To: <20080320190953.GR10722@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add helpers for the pattern put_unaligned(cpu_to_le32(val), (__le32 *)p)
to linux/unaligned.h

Repeat for various combinations of le/be and 64/32/16 bit.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Applies on top of my last patch, makes it a symmetric API.

 include/linux/unaligned.h |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/unaligned.h b/include/linux/unaligned.h
index 7d8fddc..c9aa286 100644
--- a/include/linux/unaligned.h
+++ b/include/linux/unaligned.h
@@ -37,6 +37,36 @@ static inline u16 be16_to_cpu_unaligned(void *p)
 	return __be16_to_cpu(get_unaligned((__be16 *)p));
 }
 
+static inline void cpu_to_le64_unaligned(u64 val, void *p)
+{
+	put_unaligned(cpu_to_le64(val), (__le64 *)p);
+}
+
+static inline void cpu_to_le32_unaligned(u32 val, void *p)
+{
+	put_unaligned(cpu_to_le32(val), (__le32 *)p);
+}
+
+static inline void cpu_to_le16_unaligned(u16 val, void *p)
+{
+	put_unaligned(cpu_to_le16(val), (__le16 *)p);
+}
+
+static inline void cpu_to_be64_unaligned(u64 val, void *p)
+{
+	put_unaligned(cpu_to_be64(val), (__be64 *)p);
+}
+
+static inline void cpu_to_be32_unaligned(u32 val, void *p)
+{
+	put_unaligned(cpu_to_be32(val), (__be32 *)p);
+}
+
+static inline void cpu_to_be16_unaligned(u16 val, void *p)
+{
+	put_unaligned(cpu_to_be16(val), (__be16 *)p);
+}
+
 #endif /* KERNEL */
 
 #endif /* _LINUX_UNALIGNED_H */
-- 
1.5.4.4.684.g0e08

From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 25/25] bury memcpy_toiovec()
Date: Tue,  9 Dec 2014 22:50:38 +0000
Message-ID: <1418165438-2205-25-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

no users left

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/uio.h |  1 -
 lib/iovec.c         | 25 -------------------------
 2 files changed, 26 deletions(-)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index bd8569a..a41e252 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -131,7 +131,6 @@ size_t csum_and_copy_to_iter(void *addr, size_t bytes, __wsum *csum, struct iov_
 size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum, struct iov_iter *i);
 
 int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
-int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len);
 int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			int offset, int len);
 int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
diff --git a/lib/iovec.c b/lib/iovec.c
index df3abd1..2d99cb4 100644
--- a/lib/iovec.c
+++ b/lib/iovec.c
@@ -29,31 +29,6 @@ EXPORT_SYMBOL(memcpy_fromiovec);
 
 /*
  *	Copy kernel to iovec. Returns -EFAULT on error.
- *
- *	Note: this modifies the original iovec.
- */
-
-int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len)
-{
-	while (len > 0) {
-		if (iov->iov_len) {
-			int copy = min_t(unsigned int, iov->iov_len, len);
-			if (copy_to_user(iov->iov_base, kdata, copy))
-				return -EFAULT;
-			kdata += copy;
-			len -= copy;
-			iov->iov_len -= copy;
-			iov->iov_base += copy;
-		}
-		iov++;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(memcpy_toiovec);
-
-/*
- *	Copy kernel to iovec. Returns -EFAULT on error.
  */
 
 int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
-- 
2.1.3

From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 12/25] new helper: iov_iter_kvec()
Date: Tue,  9 Dec 2014 22:50:25 +0000
Message-ID: <1418165438-2205-12-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

initialization of kvec-backed iov_iter

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/uio.h |  2 ++
 mm/iov_iter.c       | 13 +++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index 28ed2d9..c567655 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -87,6 +87,8 @@ size_t iov_iter_zero(size_t bytes, struct iov_iter *);
 unsigned long iov_iter_alignment(const struct iov_iter *i);
 void iov_iter_init(struct iov_iter *i, int direction, const struct iovec *iov,
 			unsigned long nr_segs, size_t count);
+void iov_iter_kvec(struct iov_iter *i, int direction, const struct kvec *iov,
+			unsigned long nr_segs, size_t count);
 ssize_t iov_iter_get_pages(struct iov_iter *i, struct page **pages,
 			size_t maxsize, unsigned maxpages, size_t *start);
 ssize_t iov_iter_get_pages_alloc(struct iov_iter *i, struct page ***pages,
diff --git a/mm/iov_iter.c b/mm/iov_iter.c
index 1d2cdeb..88c052e 100644
--- a/mm/iov_iter.c
+++ b/mm/iov_iter.c
@@ -479,6 +479,19 @@ size_t iov_iter_single_seg_count(const struct iov_iter *i)
 }
 EXPORT_SYMBOL(iov_iter_single_seg_count);
 
+void iov_iter_kvec(struct iov_iter *i, int direction,
+			const struct kvec *iov, unsigned long nr_segs,
+			size_t count)
+{
+	BUG_ON(!(direction & ITER_KVEC));
+	i->type = direction;
+	i->kvec = (struct kvec *)iov;
+	i->nr_segs = nr_segs;
+	i->iov_offset = 0;
+	i->count = count;
+}
+EXPORT_SYMBOL(iov_iter_kvec);
+
 unsigned long iov_iter_alignment(const struct iov_iter *i)
 {
 	unsigned long res = 0;
-- 
2.1.3

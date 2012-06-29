From: Andreas Gruenbacher <agruen@linbit.com>
Subject: [RFC] [TCP 3/3] fs: Export bio_release_pages()
Date: Fri, 29 Jun 2012 16:56:03 +0200
Message-ID: <1340981763.25226.5.camel@gurkel.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andreas Gruenbacher <agruen@linbit.com>
---
 fs/bio.c            |    3 ++-
 include/linux/bio.h |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/bio.c b/fs/bio.c
index 73922ab..90501a5 100644
--- a/fs/bio.c
+++ b/fs/bio.c
@@ -1335,7 +1335,7 @@ void bio_set_pages_dirty(struct bio *bio)
 	}
 }
 
-static void bio_release_pages(struct bio *bio)
+void bio_release_pages(struct bio *bio)
 {
 	struct bio_vec *bvec = bio->bi_io_vec;
 	int i;
@@ -1347,6 +1347,7 @@ static void bio_release_pages(struct bio *bio)
 			put_page(page);
 	}
 }
+EXPORT_SYMBOL(bio_release_pages);
 
 /*
  * bio_check_pages_dirty() will check that all the BIO's pages are still dirty.
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 2643589..268ec49 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -246,6 +246,7 @@ extern struct bio *bio_copy_kern(struct request_queue *, void *, unsigned int,
 				 gfp_t, int);
 extern void bio_set_pages_dirty(struct bio *bio);
 extern void bio_check_pages_dirty(struct bio *bio);
+extern void bio_release_pages(struct bio *bio);
 
 #ifndef ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
 # error	"You should define ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE for your platform"
-- 
1.7.10.2

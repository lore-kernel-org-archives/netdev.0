From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vmsplice: relax alignement requirements for SPLICE_F_GIFT
Date: Wed, 04 Apr 2012 11:08:51 +0200
Message-ID: <1333530531.18626.550.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Hugh Dickins <hughd@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@suse.cz>
To: Jens Axboe <axboe@kernel.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems there is no fundamental reason to limit vmsplice()
SPLICE_F_GIFT to page aligned chunks.

All helpers are prepared to cope with offsets in page.

This limitation makes vmsplice() API very impractical in the zero-copy
land.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Hugh Dickins <hughd@google.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/splice.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 5f883de..5417aa3 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1385,7 +1385,7 @@ static long do_splice(struct file *in, loff_t __user *off_in,
  */
 static int get_iovec_page_array(const struct iovec __user *iov,
 				unsigned int nr_vecs, struct page **pages,
-				struct partial_page *partial, int aligned,
+				struct partial_page *partial, bool aligned,
 				unsigned int pipe_buffers)
 {
 	int buffers = 0, error = 0;
@@ -1623,7 +1623,7 @@ static long vmsplice_to_pipe(struct file *file, const struct iovec __user *iov,
 		return -ENOMEM;
 
 	spd.nr_pages = get_iovec_page_array(iov, nr_segs, spd.pages,
-					    spd.partial, flags & SPLICE_F_GIFT,
+					    spd.partial, false,
 					    pipe->buffers);
 	if (spd.nr_pages <= 0)
 		ret = spd.nr_pages;

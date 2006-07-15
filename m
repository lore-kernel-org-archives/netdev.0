From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] remove net/core/skbuff.c:skb_queue_lock_key
Date: Sat, 15 Jul 2006 02:35:19 +0200
Message-ID: <20060715003519.GF3633@stusta.de>
References: <20060713224800.6cbdbf5d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:28681 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1945936AbWGOAfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 20:35:20 -0400
To: Andrew Morton <akpm@osdl.org>, arjan@linux.intel.com
Content-Disposition: inline
In-Reply-To: <20060713224800.6cbdbf5d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 10:48:00PM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.18-rc1-mm1:
>...
> +lockdep-split-the-skb_queue_head_init-lock-class.patch
> 
>  lockdep-versus-net fix.
>...

skb_queue_lock_key is no longer used.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/linux/skbuff.h |    2 --
 net/core/skbuff.c      |    7 -------
 2 files changed, 9 deletions(-)

--- linux-2.6.18-rc1-mm2-full/include/linux/skbuff.h.old	2006-07-14 22:15:15.000000000 +0200
+++ linux-2.6.18-rc1-mm2-full/include/linux/skbuff.h	2006-07-14 22:15:23.000000000 +0200
@@ -604,8 +604,6 @@
 	return list_->qlen;
 }
 
-extern struct lock_class_key skb_queue_lock_key;
-
 /*
  * This function creates a split out lock class for each invocation;
  * this is needed for now since a whole lot of users of the skb-queue
--- linux-2.6.18-rc1-mm2-full/net/core/skbuff.c.old	2006-07-14 22:15:30.000000000 +0200
+++ linux-2.6.18-rc1-mm2-full/net/core/skbuff.c	2006-07-14 22:15:38.000000000 +0200
@@ -71,13 +71,6 @@
 static kmem_cache_t *skbuff_fclone_cache __read_mostly;
 
 /*
- * lockdep: lock class key used by skb_queue_head_init():
- */
-struct lock_class_key skb_queue_lock_key;
-
-EXPORT_SYMBOL(skb_queue_lock_key);
-
-/*
  *	Keep out-of-line to prevent kernel bloat.
  *	__builtin_return_address is not used because it is not always
  *	reliable.


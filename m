From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 12:16:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810291215220.32108@melkki.cs.Helsinki.FI>
References: <20081028175604.81c31cea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>, Takashi Iwai <tiwai@suse.de>,
	xfs-masters@oss.sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54405 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbYJ2KQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 06:16:53 -0400
In-Reply-To: <20081028175604.81c31cea.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Oct 2008, Andrew Morton wrote:
> > include/linux/slub_def.h:231: warning: 'ret' might be used uninitialized in this function
> > include/linux/slub_def.h:231: warning: 'ret' might be used uninitialized in this function
> 
> I lost interest here.

Looks like a bogus warning to me. But we might as well clean it up a bit 
and maybe the compiler is less confused that way.

		Pekka

>From 48724e2995a0fd292d326f79caebe61f4f115021 Mon Sep 17 00:00:00 2001
From: Pekka Enberg <penberg@cs.helsinki.fi>
Date: Wed, 29 Oct 2008 12:13:37 +0200
Subject: [PATCH] slub: avoid bogus warning on arm

Move the ret variable to where we actually need it in an attempt to avoid a
bugs warning when compiling for ARM.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 include/linux/slub_def.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index dc28432..4d3de0c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -228,14 +228,13 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
-	void *ret;
-
 	if (__builtin_constant_p(size)) {
 		if (size > PAGE_SIZE)
 			return kmalloc_large(size, flags);
 
 		if (!(flags & SLUB_DMA)) {
 			struct kmem_cache *s = kmalloc_slab(size);
+			void *ret;
 
 			if (!s)
 				return ZERO_SIZE_PTR;
-- 
1.5.4.3


From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/7] slab: infrastructure for bulk object allocation and
 freeing
Date: Tue, 16 Jun 2015 14:44:41 -0700
Message-ID: <20150616144441.65bead5677fc13f86b5244f2@linux-foundation.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155156.18824.35187.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37166 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbFPVom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 17:44:42 -0400
In-Reply-To: <20150615155156.18824.35187.stgit@devil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2015 17:51:56 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> +bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> +								void **p)
> +{
> +	return kmem_cache_alloc_bulk(s, flags, size, p);
> +}

hm, any call to this function is going to be nasty, brutal and short.

--- a/mm/slab.c~slab-infrastructure-for-bulk-object-allocation-and-freeing-v3-fix
+++ a/mm/slab.c
@@ -3425,7 +3425,7 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 								void **p)
 {
-	return kmem_cache_alloc_bulk(s, flags, size, p);
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 
_

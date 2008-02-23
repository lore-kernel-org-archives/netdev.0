From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Sat, 23 Feb 2008 00:04:48 -0800
Message-ID: <20080223000448.9dadd2c5.akpm@linux-foundation.org>
References: <47BDBC23.10605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Christoph Lameter <clameter@sgi.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:34151 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933254AbYBWIJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 03:09:19 -0500
In-Reply-To: <47BDBC23.10605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Feb 2008 19:00:03 +0100 Eric Dumazet <dada1@cosmosbay.com> wrote:

> +#ifndef cache_line_size
> +#define cache_line_size()	L1_CACHE_BYTES
> +#endif

argh, you made me look.

Really cache_line_size() should be implemented in include/linux/cache.h. 
Then we tromp the stupid private implementations in slob.c and slub.c.

Then we wonder why x86 uses a custom cache_line_size(), but still uses
L1_CACHE_BYTES for its L1_CACHE_ALIGN().

Once we've answered that, we look at your

+	/*
+	 * We should make sure each CPU gets private memory.
+	 */
+	size = roundup(size, cache_line_size());

and wonder whether it should have used L1_CACHE_ALIGN().

I think I'd better stop looking.

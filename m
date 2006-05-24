From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/9] [I/OAT] Driver for the Intel(R) I/OAT DMA engine
Date: Tue, 23 May 2006 17:56:28 -0700
Message-ID: <20060523175628.22a741ba.akpm@osdl.org>
References: <20060524001653.19403.31396.stgit@gitlost.site>
	<20060524002013.19403.57410.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48529 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932525AbWEXA4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 20:56:49 -0400
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060524002013.19403.57410.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> +static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *chan)
>  +{
>  +	unsigned long phys_complete;
>  +	struct ioat_desc_sw *desc, *_desc;
>  +	dma_cookie_t cookie = 0;
>  +
>  +	prefetch(chan->completion_virt);
>  +
>  +	if (!spin_trylock(&chan->cleanup_lock))
>  +		return;
>  +

spin_trylock() is a red flag.  It often means that someone screwed their
locking up.

It at least needs a comment explaining its presence.

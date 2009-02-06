From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and
 private channels
Date: Sat, 07 Feb 2009 01:58:25 +0900 (JST)
Message-ID: <20090207.015825.95063161.anemo@mba.ocn.ne.jp>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	<20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: dan.j.williams@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754031AbZBFQ6m@vger.kernel.org>
In-Reply-To: <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Nov 2008 14:34:53 -0700, Dan Williams <dan.j.williams@intel.com> wrote:
> To ensure that all channels are not consumed by the general-purpose
> allocator the DMA_PRIVATE capability is provided to exclude a dma_device
> from general-purpose (memory-to-memory) consideration.
...
> +			/* Found a suitable channel, try to grab, prep, and
> +			 * return it.  We first set DMA_PRIVATE to disable
> +			 * balance_ref_count as this channel will not be
> +			 * published in the general-purpose allocator
> +			 */
> +			dma_cap_set(DMA_PRIVATE, device->cap_mask);
> +			err = dma_chan_get(chan);

The dma_request_channel() set DMA_PRIVATE but dma_release_channel()
does not clear it.

If a client (such as dmatest) grabbed a public channel by
dma_request_channel(), the channel will stay private forever.

While a dma driver might set DMA_PRIVATE initially for private-only
channels, dma_release_channel() cannot clear it unconditionally.

How can this solved?  DMA_ALWAYS_PRIVATE or device->is_private or
something will needed?

---
Atsushi Nemoto

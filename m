From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and
	private channels
Date: Fri, 30 Jan 2009 16:13:12 -0700
Message-ID: <e9c3a7c20901301513v74953d7aj8533d05cddfa510@mail.gmail.com>
References: <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
	 <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
	 <e9c3a7c20812020916ud0b426cvd0764f23a97973ad@mail.gmail.com>
	 <20090131.020300.82352947.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: g.liakhovetski@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, maciej.sosnowski@intel.com,
	hskinnemoen@atmel.com, nicolas.ferre@atmel.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:8770 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbZA3XNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:13:13 -0500
In-Reply-To: <20090131.020300.82352947.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 10:03 AM, Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> I'm writing a new dma driver.  My DMAC has multiple channels and only
> one channel is capable for generic memcpy and other channels have
> fixed role.
>
> Does new framework allow dma driver make only one channel public?

Yes, if the driver registers a dma_device for each channel.

> Or should I register two dma_device for DMA_MEMCPY and DMA_SLAVE?
> Could you give me some advice?

Register multiple dma_devices, the public one with a DMA_MEMCPY, and
the fixed role devices with DMA_PRIVATE, DMA_MEMCPY, and DMA_SLAVE
capabilities.

DMA_PRIVATE ensures that a channel is never considered for public consumption.

--
Dan

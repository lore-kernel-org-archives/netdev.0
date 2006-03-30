From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/9] I/OAT
Date: Thu, 30 Mar 2006 10:21:24 +0400
Message-ID: <20060330062124.GA8545@2ka.mipt.ru>
References: <1143672844.27644.5.camel@black-lazer.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751237AbWC3HVl@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <1143672844.27644.5.camel@black-lazer.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2006 at 02:54:04PM -0800, Chris Leech (christopher.leech@intel.com) wrote:
> [I/OAT] Driver for the Intel(R) I/OAT DMA engine
> 
> From: Chris Leech <christopher.leech@intel.com>
> 
> Adds a new ioatdma driver
> 
> Signed-off-by: Chris Leech <christopher.leech@intel.com>

Let's do it again.
Could you please describe how struct ioat_dma_chan channels are freed?
For example when device is removed just after it has been added.

ioat_probe() -> enumerate_dma_channels() (failures are ok now) ->
kmalloc a lot of channels.

ioat_remove() -> dma_async_device_unregister() which does not cleanup
ioat_dma_chan channels, but only clients.
It ends up in dma_async_device_cleanup() only.

-- 
	Evgeniy Polyakov

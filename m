From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/8] [I/OAT] Driver for the Intel(R) I/OAT DMA engine
Date: Sun, 12 Mar 2006 13:47:28 +0300
Message-ID: <20060312104728.GA25301@2ka.mipt.ru>
References: <E3A930D59AFC3345AEBA35189102A8A6060E15E7@orsmsx404.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932110AbWCLKri@vger.kernel.org>
To: "Leech, Christopher" <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <E3A930D59AFC3345AEBA35189102A8A6060E15E7@orsmsx404.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2006 at 06:29:46PM -0800, Leech, Christopher (christopher.leech@intel.com) wrote:
> From: Chris Leech [mailto:christopher.leech@intel.com] 
> Sent: Friday, March 10, 2006 6:29 PM
> To: 
> Subject: [PATCH 2/8] [I/OAT] Driver for the Intel(R) I/OAT DMA engine
> 
> 
> Adds a new ioatdma driver

enumerate_dma_channels() is still broken, if it can not fail add NOFAIL
gfp flag.
And you play tricky games with common_node/device_node of struct
dma_chan - one of that lists is never protected, while other is called 
under RCU and other locks (btw, why does insertion use RCU and deletion
in dma_async_device_unregister() does not?).
struct ioat_dma_chan - is it somewhere freed?

-- 
	Evgeniy Polyakov

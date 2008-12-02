From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and private channels
Date: Tue, 2 Dec 2008 10:16:05 -0700
Message-ID: <e9c3a7c20812020916ud0b426cvd0764f23a97973ad@mail.gmail.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
	 <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	nicolas.ferre@atmel.com
To: "Guennadi Liakhovetski" <g.liakhovetski@gmx.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755777AbYLBRQV@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 2, 2008 at 8:52 AM, Guennadi Liakhovetski
<g.liakhovetski@gmx.de> wrote:
> Hi Dan,
>
> I think, there is a problem with your dma_request_channel() /
> private_candidate() implementation: your current version only tries one
> channel from a dma device list, which matched capabilities. If this
> channel is not accepted by the client, you do not try other channels from
> this device and just go to the next one...
>

Which dma driver are you using?  The dmaengine code assumes that all
channels on a device are equal.  It sounds like there are differences
between peer-channels on the device in this case.  If the driver
registers a device per channel that should give the flexibility you
want.

> Another problem I encountered with my framebuffer is the initialisation
> order. You initialise dmaengine per subsys_initcall(), whereas the only
> way to guarantee the order:
>
> dmaengine
> dma-device driver
> framebuffer
>

hmm... can the framebuffer be moved to late_initcall?

Regards,
Dan

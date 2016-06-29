From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 17:34:57 +0200
Message-ID: <3914163.aNiIdzedWT@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org> <5679359.84lXZytcOR@wuerfel> <5773E503.3070404@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <5773E503.3070404@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 29, 2016 10:10:59 AM CEST Timur Tabi wrote:
> Arnd Bergmann wrote:
> > That's also not how it works: each device starts out with a 32-bit mask,
> > because that's what historically all PCI devices can do. If a device
> > is 64-bit DMA capable, it can extend the mask by passing DMA_BIT_MASK(64)
> > (or whatever it can support), and the platform code checks if that's
> > possible.
> 
> So if it's not possible, then dma_set_mask returns an error, and the 
> driver should try a smaller mask?  Doesn't that mean that every driver 
> for a 64-bit device should do this:
> 
>         for (i = 64; i >=32; i--) {
>                 ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(i));
>                 if (!ret)
>                         break;
>         }
> 
>         if (ret)
>                 return ret;
> 
> Sure, this is overkill, but it seems to me that the driver does not 
> really know what mask is actually valid, so it has to find the largest 
> mask that works.
> 

Usually drivers try 64-bit mask and 32-bit masks, and the 32 bit
mask is practically guaranteed to succeed.

Platforms will also allow allow the driver to set a mask that
is larger than what the bus supports, as long as all RAM is
reachable by the bus.

	Arnd

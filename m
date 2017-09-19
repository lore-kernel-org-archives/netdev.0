From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] net: mvpp2: fix the dma_mask and
 coherent_dma_mask settings for PPv2.2
Date: Mon, 18 Sep 2017 17:18:58 -0700 (PDT)
Message-ID: <20170918.171858.667084185425779267.davem@davemloft.net>
References: <20170918130408.23114-1-antoine.tenart@free-electrons.com>
        <20170918130408.23114-2-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918130408.23114-2-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 18 Sep 2017 15:04:06 +0200

> The dev->dma_mask usually points to dev->coherent_dma_mask. This is an
> issue as setting both of them will override the other. This is
> problematic here as the PPv2 driver uses a 32-bit-mask for coherent
> accesses (txq, rxq, bm) and a 40-bit mask for all other accesses due to
> an hardware limitation.
> 
> This can lead to a memory remap for all dma_map_single() calls when
> dealing with memory above 4GB.
> 
> Fixes: 2067e0a13cfe ("net: mvpp2: set dma mask and coherent dma mask on PPv2.2")
> Reported-by: Stefan Chulski <stefanc@marvell.com>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Yikes.

I surrmise that if the platform has made dev->dma_mask point to
&dev->coherent_dma_mask, it is because it does not allow the two
settings to be set separately.

By rearranging the pointer, you are bypassing that, and probably
breaking things or creating a situation that the DMA mapping
layer is not expecting.

I want to know more about the situations where dma_mask is set to
point to &coherent_dma_mask and how that is supposed to work.

At a minimum this commit log message needs to go into more detail.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: atm: eni: Add pci_dma_mapping_error() call
Date: Mon, 10 Nov 2014 15:32:28 -0500 (EST)
Message-ID: <20141110.153228.2187951801277440496.davem@davemloft.net>
References: <1415463482-8013-1-git-send-email-tinajohnson.1234@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: tinajohnson.1234@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415463482-8013-1-git-send-email-tinajohnson.1234@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tina Johnson <tinajohnson.1234@gmail.com>
Date: Sat,  8 Nov 2014 21:48:02 +0530

> Added a pci_dma_mapping_error() call to check for mapping errors before
> further using the dma handle. Unchecked dma handles were found using
> Coccinelle:
> 
> @rule1@
> expression e1;
> identifier x;
> @@
> 
> *x = pci_map_single(...);
>  ... when != pci_dma_mapping_error(e1,x)
> 
> Signed-off-by: Tina Johnson <tinajohnson.1234@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

I really don't like quick fixes like this, exactly because of the
kind of new bug this change is introducing.

The 'trouble' label assumes that it is recovering and unwinding state
when an error occurs after the DMA buffer is successfully mapped.

It unconditionally does pci_unmap_single() if 'paddr' is non-zero
which it might be in the error case depending upon how DMA errors
are represented on a given platform.

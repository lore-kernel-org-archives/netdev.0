From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND v3] 3c59x: fix bad split of
 cpu_to_le32(pci_map_single())
Date: Tue, 07 Oct 2014 13:16:46 -0400 (EDT)
Message-ID: <20141007.131646.1417551297088545264.davem@davemloft.net>
References: <20141007134034.GA8838@erable>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nhorman@tuxdriver.com,
	mroos@linux.ee, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: sylvain.hitier@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141007134034.GA8838@erable>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sylvain 'ythier' Hitier <sylvain.hitier@gmail.com>
Date: Tue, 7 Oct 2014 13:40:34 +0000

> From: Sylvain "ythier" Hitier <sylvain.hitier@gmail.com>
> 
> In commit 6f2b6a3005b2c34c39f207a87667564f64f2f91a,
>   # 3c59x: Add dma error checking and recovery
> the intent is to split out the mapping from the byte-swapping in order to
> insert a dma_mapping_error() check.
> 
> Kinda this semantic patch:
> 
>     // See http://coccinelle.lip6.fr/
>     //
>     // Beware, grouik-and-dirty!
>     @@
>     expression DEV, X, Y, Z;
>     @@
>     -   cpu_to_le32(pci_map_single(DEV, X, Y, Z))
>     +   dma_addr_t addr = pci_map_single(DEV, X, Y, Z);
>     +   if (dma_mapping_error(&DEV->dev, addr))
>     +       /* snip */;
>     +   cpu_to_le32(addr)
> 
> However, the #else part (of the #if DO_ZEROCOPY test) is changed this way:
> 
>     -   cpu_to_le32(pci_map_single(DEV, X, Y, Z))
>     +   dma_addr_t addr = cpu_to_le32(pci_map_single(DEV, X, Y, Z));
>     //                    ^^^^^^^^^^^
>     //                    That mismatches the 3 other changes!
>     +   if (dma_mapping_error(&DEV->dev, addr))
>     +       /* snip */;
>     +   cpu_to_le32(addr)
> 
> Let's remove the leftover cpu_to_le32() for coherency.
> 
> v2: Better changelog.
> v3: Add Acked-by
> 
> Fixes: 6f2b6a3005b2c34c39f207a87667564f64f2f91a
>   # 3c59x: Add dma error checking and recovery
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Sylvain "ythier" Hitier <sylvain.hitier@gmail.com>

Applied and queued up for -stable, thanks!

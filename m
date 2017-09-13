From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/10] arch:powerpc: return -ENOMEM on failed allocation
Date: Wed, 13 Sep 2017 07:53:21 -0700
Message-ID: <1505314401.8969.11.camel@perches.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nouveau@lists.freedesktop.org, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org, MPT-FusionLinux.pdl@broadcom.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        megaraidlinux.pdl@broadcom.com, target-devel@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-btrfs@vger.kernel.org
To: Allen Pais <allen.lkml@gmail.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-13 at 13:02 +0530, Allen Pais wrote:
> Signed-off-by: Allen Pais <allen.lkml@gmail.com>

I think the changelog for this series of conversions
should show that you've validated the change by
inspecting the return call chain at each modified line.

Also, it seems you've cc'd the same mailing lists for
all of the patches modified by this series.

It would be better to individually address each patch
in the series only cc'ing the appropriate maintainers
and mailing lists.

A cover letter would be good too.

> ---
>  arch/powerpc/platforms/cell/spider-pci.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/cell/spider-pci.c b/arch/powerpc/platforms/cell/spider-pci.c
> index d1e61e2..82aa3f7 100644
> --- a/arch/powerpc/platforms/cell/spider-pci.c
> +++ b/arch/powerpc/platforms/cell/spider-pci.c
> @@ -106,7 +106,7 @@ static int __init spiderpci_pci_setup_chip(struct pci_controller *phb,
>  	dummy_page_va = kmalloc(PAGE_SIZE, GFP_KERNEL);
>  	if (!dummy_page_va) {
>  		pr_err("SPIDERPCI-IOWA:Alloc dummy_page_va failed.\n");
> -		return -1;
> +		return -ENOMEM;
>  	}
>  
>  	dummy_page_da = dma_map_single(phb->parent, dummy_page_va,
> @@ -137,7 +137,7 @@ int __init spiderpci_iowa_init(struct iowa_bus *bus, void *data)
>  	if (!priv) {
>  		pr_err("SPIDERPCI-IOWA:"
>  		       "Can't allocate struct spiderpci_iowa_private");
> -		return -1;
> +		return -ENOMEM;
>  	}
>  
>  	if (of_address_to_resource(np, 0, &r)) {

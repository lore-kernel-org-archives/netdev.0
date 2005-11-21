From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Tue, 22 Nov 2005 07:37:58 +1100
Message-ID: <20051121203758.GA25509@gondor.apana.org.au>
References: <E1EdmMo-00020b-00@gondolin.me.apana.org.au> <438097D2.9020607@student.ltu.se> <20051120204001.GA11043@gondor.apana.org.au> <4381C321.5010805@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932455AbVKUUiV@vger.kernel.org>
To: Richard Knutsson <ricknu-0@student.ltu.se>
Content-Disposition: inline
In-Reply-To: <4381C321.5010805@student.ltu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2005 at 01:52:49PM +0100, Richard Knutsson wrote:
>
> What do you think about this patch? Will you sign it? It is no longer an 
> error-warning-fix but a bug-fix (and some cleanup).
> I "took" you implementation of dgrs_(un)register_eisa(), especially 
> since eisa needed to be unregistered if pci succeeds (I take you word 
> for it to be so).
> (BTW, this patch is compiled with CONFIG_PCI set, CONFIG_EISA set and 
> both set without errors/warnings for dgrs.o.)
> 
> This patch requirer the 
> "net-fix-compiler-error-on-dgrsc-when-config_pci.patch" (added to the 
> -mm tree after 2.6.15-rc1-mm2):
> 
> --- 
> devel/drivers/net/dgrs.c~net-fix-compiler-error-on-dgrsc-when-config_pci 
> 2005-11-19 18:00:34.000000000 -0800
> +++ devel-akpm/drivers/net/dgrs.c	2005-11-19 18:00:34.000000000 -0800
> @@ -1458,6 +1458,8 @@ static struct pci_driver dgrs_pci_driver
> 	.probe = dgrs_pci_probe,
> 	.remove = __devexit_p(dgrs_pci_remove),
> };
> +#else
> +static struct pci_driver dgrs_pci_driver = {};
> #endif

I don't see the point.  We shouldn't have this structure at all
if CONFIG_PCI is not set.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

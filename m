From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Mon, 21 Nov 2005 22:47:18 +0100
Message-ID: <43824066.4080109@student.ltu.se>
References: <E1EdmMo-00020b-00@gondolin.me.apana.org.au> <438097D2.9020607@student.ltu.se> <20051120204001.GA11043@gondor.apana.org.au> <4381C321.5010805@student.ltu.se> <20051121203758.GA25509@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751084AbVKUVmq@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051121203758.GA25509@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Mon, Nov 21, 2005 at 01:52:49PM +0100, Richard Knutsson wrote:
>  
>
>>This patch requirer the 
>>"net-fix-compiler-error-on-dgrsc-when-config_pci.patch" (added to the 
>>-mm tree after 2.6.15-rc1-mm2):
>>
>>--- 
>>devel/drivers/net/dgrs.c~net-fix-compiler-error-on-dgrsc-when-config_pci 
>>2005-11-19 18:00:34.000000000 -0800
>>+++ devel-akpm/drivers/net/dgrs.c	2005-11-19 18:00:34.000000000 -0800
>>@@ -1458,6 +1458,8 @@ static struct pci_driver dgrs_pci_driver
>>	.probe = dgrs_pci_probe,
>>	.remove = __devexit_p(dgrs_pci_remove),
>>};
>>+#else
>>+static struct pci_driver dgrs_pci_driver = {};
>>#endif
>>    
>>
>
>I don't see the point.  We shouldn't have this structure at all
>if CONFIG_PCI is not set.
>
>Cheers,
>
We need it even if pci_register_driver() and pci_register_driver() is 
empty shells. And instead of removing #endif CONFIG_PCI for 
dgrs_pci_driver, which needs dgrs_pci_tbl, dgrs_pci_probe() and 
dgrs_pci_remove() (and so on), I added the empty dgrs_pci_driver-structure.

cu,

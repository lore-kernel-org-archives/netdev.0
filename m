From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Tue, 22 Nov 2005 00:20:30 +0100
Message-ID: <4382563E.50502@student.ltu.se>
References: <E1EeJu8-0006vr-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932475AbVKUXPs@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1EeJu8-0006vr-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Richard Knutsson <ricknu-0@student.ltu.se> wrote:
>  
>
>>We need it even if pci_register_driver() and pci_register_driver() is 
>>empty shells. And instead of removing #endif CONFIG_PCI for 
>>    
>>
>
>I don't think so.  Please see my previous patch where pci_register_driver
>is not called at all if CONFIG_PCI is not defined.
>
>Cheers,
>  
>
Yes, I know you patch don't need it (thought you commented the patch vs. 
dgrs.c, not vs. you patch). But to do that, you have to introduce a new 
dgrs-specific pci-layer to compensate. If you don't want to have an 
empty struct, is it not nicer/easier to just #ifdef CONFIG_PCI the 
pci_*-functions? (instead of two inline functions for every used 
pci_*-function?)

Am thinking of removing the #ifdef CONFIG_PCI's in other files, to 
"clean up" the code, but that would introduce this problem again, don't 
you think it is more readable to make an empty struct when !CONFIG_PCI, 
then making new pci_*-functions specific to the driver?

cu

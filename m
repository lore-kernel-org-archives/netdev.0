From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [Linaro-acpi] [V2 PATCH 2/5] arm64 : Introduce support for ACPI
 _CCA object
Date: Tue, 5 May 2015 11:24:03 -0500
Message-ID: <5548EEA3.8010101@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <5126612.k0u2CL2zi5@wuerfel> <5548EB42.5010800@amd.com>
 <8157862.NJP1L4Rh25@wuerfel> <5548EC47.3020501@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rjw@rjwysocki.net>, <herbert@gondor.apana.org.au>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<lenb@kernel.org>
To: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	Arnd Bergmann <arnd@arndb.de>, <linaro-acpi@lists.linaro.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <5548EC47.3020501@amd.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/05/2015 11:13 AM, Suravee Suthikulanit wrote:
> On 5/5/2015 11:12 AM, Arnd Bergmann wrote:
>> On Tuesday 05 May 2015 11:09:38 Suravee Suthikulanit wrote:
>>>
>>> However, codes in several places are making use of dma_map_ops without
>>> checking if the ops are NULL (i.e.
>>> include/asm-generic/dma-mapping-common.h and in arch-specific
>>> implementation). If setting it to NULL is what we are planning to
>>> support, we would need to scrub the current code to put NULL check.
>>> Also, would you consider if that is safe to do going forward?
>>>
>>>
>>
>> I mean the dma_mask pointer, not dma_map_ops.

Except a lot of drivers will actually set the dma_mask pointer during
probe (usually by setting dev->dma_mask = &dev->coherent_dma_mask or by
calling dma_coerce_mask_and_coherent).  So I think the dummy_dma_ops
might be the safest way to go.

Thanks,
Tom

>>
>>     Arnd
>>
>
> Ah, got it. Sorry for confusion.
>
> Suravee
>
> _______________________________________________
> Linaro-acpi mailing list
> Linaro-acpi@lists.linaro.org
> https://lists.linaro.org/mailman/listinfo/linaro-acpi

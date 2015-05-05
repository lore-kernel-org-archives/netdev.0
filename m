From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-acpi] [V2 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Tue, 05 May 2015 20:02:53 +0200
Message-ID: <9405327.TMH3y4SfqS@wuerfel>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com> <5548EC47.3020501@amd.com> <5548EEA3.8010101@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	linaro-acpi@lists.linaro.org, rjw@rjwysocki.net,
	herbert@gondor.apana.org.au, catalin.marinas@arm.com,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lenb@kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:53348 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965923AbbEESDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 14:03:05 -0400
In-Reply-To: <5548EEA3.8010101@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 May 2015 11:24:03 Tom Lendacky wrote:
> On 05/05/2015 11:13 AM, Suravee Suthikulanit wrote:
> > On 5/5/2015 11:12 AM, Arnd Bergmann wrote:
> >> On Tuesday 05 May 2015 11:09:38 Suravee Suthikulanit wrote:
> >>>
> >>> However, codes in several places are making use of dma_map_ops without
> >>> checking if the ops are NULL (i.e.
> >>> include/asm-generic/dma-mapping-common.h and in arch-specific
> >>> implementation). If setting it to NULL is what we are planning to
> >>> support, we would need to scrub the current code to put NULL check.
> >>> Also, would you consider if that is safe to do going forward?
> >>>
> >>>
> >>
> >> I mean the dma_mask pointer, not dma_map_ops.
> 
> Except a lot of drivers will actually set the dma_mask pointer during
> probe (usually by setting dev->dma_mask = &dev->coherent_dma_mask or by
> calling dma_coerce_mask_and_coherent).  So I think the dummy_dma_ops
> might be the safest way to go.

Those drivers are broken already, I don't think we should worry about
them. Let's just fix them properly when we run into problems with them.

Basically any use of dma_coerce_mask_and_coherent() is an annotation
for a bug where a driver used to set dev->dma_mask = &dev->coherent_dma_mask
manually.

	Arnd

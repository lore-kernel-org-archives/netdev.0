From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Thu, 12 May 2016 09:58:04 +0200
Message-ID: <CAKv+Gu-UcEnvFcK+6GSHkas5V5ZUMawc2K_EfRpW3K+jLNB4+A@mail.gmail.com>
References: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
	<20160511.195853.1708987256480186664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	Leo Duran <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35590 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbcELH6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 03:58:06 -0400
Received: by mail-io0-f177.google.com with SMTP id d62so85197430iof.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 00:58:05 -0700 (PDT)
In-Reply-To: <20160511.195853.1708987256480186664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 May 2016 at 01:58, David Miller <davem@davemloft.net> wrote:
> From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Date: Wed, 11 May 2016 09:47:49 +0200
>
>> The current logic around the 'use_dac' module parameter prevents the
>> r81969 driver from being loadable on 64-bit systems without any RAM
>> below 4 GB when the parameter is left at its default value.
>> So introduce a new default value -1 which indicates that 64-bit DMA
>> should be enabled implicitly, but only if setting a 32-bit DMA mask
>> has failed earlier. This should prevent any regressions like the ones
>> caused by previous attempts to change this code.
>>
>> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>
> I think we should just seriously consider changing the default, it's
> a really outdated reasoning behind the current default setting.  Maybe
> relevant a decade ago, but probably not now.
>
> And if the card is completely disfunctional in said configuration, the
> default is definitely wrong.

The card is indeed completely disfunctional. So we could try to
resurrect 353176888386 ("r8169: enable 64-bit DMA by default for PCI
Express devices"), and instead of backing it out again if regressions
are reported, blacklist the particular chips. This is a much better
approach, since then we can also print some kind of diagnostic on
those arm64 systems why such a blacklisted NIC is not supported.

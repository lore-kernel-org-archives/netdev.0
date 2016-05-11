From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Wed, 11 May 2016 22:34:13 +0200
Message-ID: <CAKv+Gu95h2WPXDvwWjOkYH8A11RysCXBcvti62hvXo1J7zgwEA@mail.gmail.com>
References: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
	<20160511203126.GA10093@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ricardo Salveti <ricardo.salveti@linaro.org>,
	Leo Duran <leo.duran@amd.com>,
	G Gregory <graeme.gregory@linaro.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37589 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbcEKUeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 16:34:14 -0400
Received: by mail-ig0-f182.google.com with SMTP id s8so41006362ign.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 13:34:14 -0700 (PDT)
In-Reply-To: <20160511203126.GA10093@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 May 2016 at 22:31, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Ard Biesheuvel <ard.biesheuvel@linaro.org> :
>> The current logic around the 'use_dac' module parameter prevents the
>> r81969 driver from being loadable on 64-bit systems without any RAM
>> below 4 GB when the parameter is left at its default value.
>> So introduce a new default value -1 which indicates that 64-bit DMA
>> should be enabled implicitly, but only if setting a 32-bit DMA mask
>> has failed earlier. This should prevent any regressions like the ones
>> caused by previous attempts to change this code.
>
> I am not a huge fan but if you really need it...
>
> Which current kernel arches do exhibit the interesting
> f*ck-legacy-32-bits-only-devices property you just described ?
>

It has little to do with f*cking legacy 32-bits-only-devices if DRAM
simply starts at 0x80_0000_0000. This is on an AMD arm64 chip.

> [...]
>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
>> index 94f08f1e841c..a49e8a58e539 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
> [...]
>> @@ -859,7 +859,8 @@ struct rtl8169_private {
>>  MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
>>  MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
>>  module_param(use_dac, int, 0);
>> -MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
>> +MODULE_PARM_DESC(use_dac,
>> +     "Enable PCI DAC. Unsafe on 32 bit PCI slot (default -1: enable on 64-bit archs only if needed");
>
> Nit: the parameter is bizarre enough that you could leave the original
> description.
>

OK, if you prefer. Should I send a v2?

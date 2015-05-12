From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V3 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Tue, 12 May 2015 10:06:01 -0500
Message-ID: <555216D9.30506@amd.com>
References: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <3684853.vaQGhc4jR5@vostro.rjw.lan>
 <20150511161626.GI18655@e104818-lin.cambridge.arm.com>
 <1664523.WMm4AqWTY5@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <thomas.lendacky@amd.com>, <linux-crypto@vger.kernel.org>,
	<herbert@gondor.apana.org.au>, <arnd@arndb.de>,
	<linaro-acpi@lists.linaro.org>, <will.deacon@arm.com>,
	<linux-kernel@vger.kernel.org>, <al.stone@linaro.org>,
	<linux-acpi@vger.kernel.org>, <netdev@vger.kernel.org>,
	<leo.duran@amd.com>, <hanjun.guo@linaro.org>, <msalter@redhat.com>,
	<grant.likely@linaro.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <lenb@kernel.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1664523.WMm4AqWTY5@vostro.rjw.lan>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/11/2015 8:20 PM, Rafael J. Wysocki wrote:
> On Monday, May 11, 2015 05:16:27 PM Catalin Marinas wrote:
>> On Fri, May 08, 2015 at 10:53:59PM +0200, Rafael J. Wysocki wrote:
>>> On Thursday, May 07, 2015 07:37:12 PM Suravee Suthikulpanit wrote:
>>>> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
>>>> index ab2cbb5..7822149 100644
>>>> --- a/drivers/acpi/Kconfig
>>>> +++ b/drivers/acpi/Kconfig
>>>> @@ -54,6 +54,12 @@ config ACPI_GENERIC_GSI
>>>>   config ACPI_SYSTEM_POWER_STATES_SUPPORT
>>>>   	bool
>>>>
>>>> +config ACPI_CCA_REQUIRED
>>>> +	bool
>>>> +
>>>> +config ARM64_SUPPORT_ACPI_CCA_ZERO
>>>
>>> Hmm.  I guess the Arnd's idea what to simply use CONFIG_ARM64 directly instead
>>> of adding this new option.
>>
>> I agree.
>>
>>>> +static inline bool acpi_dma_is_supported(struct acpi_device *adev)
>>>> +{
>>>> +	/**
>>>> +	 * Currently, we mainly support _CCA=1 (i.e. is_coherent=1)
>>>> +	 * This should be equivalent to specifyig dma-coherent for
>>>> +	 * a device in OF.
>>>> +	 *
>>>> +	 * For the case when _CCA=0 (i.e. is_coherent=0 && cca_seen=1),
>>>> +	 * we would rely on arch-specific cache maintenance for
>>>> +	 * non-coherence DMA operations if architecture specifies
>>>> +	 * _XXX_SUPPORT_CCA_ZERO. Otherwise, we do not support
>>>> +	 * DMA on this device and fallback to arch-specific default
>>>> +	 * handling.
>>>> +	 *
>>>> +	 * For the case when _CCA is missing (i.e. cca_seen=0) but
>>>> +	 * platform specifies ACPI_CCA_REQUIRED, we do not support DMA,
>>>> +	 * and fallback to arch-specific default handling.
>>>> +	 */
>>>> +	return adev && (adev->flags.is_coherent ||
>>>> +			(adev->flags.cca_seen &&
>>>> +			 IS_ENABLED(CONFIG_ARM64_SUPPORT_ACPI_CCA_ZERO)));
>>>
>>> So what exactly would be wrong with using IS_ENABLED(CONFIG_ARM64) here?
>>
>> I'm not sure I follow why we need to check for ARM64 here at all. Can we
>> not just have something like:
>>
>> 	return adev && (!IS_ENABLED(CONFIG_ACPI_CCA_REQUIRED) ||
>> 			adev->flags.cca_seen)
>
> If _CCA returns 0 on non-ARM64, DMA is not supported for this device, so
> in that case the function should return 'false' while the above check will
> make it return 'true'.
>

The main idea is basically to allow architecture to decide if it wants 
to specify if it wants to support _CCA=0. Currently, there are two 
approaches.
1. Do not support and disable DMA
2. Support and default to what architecture would normally do for 
non-coherent DMA.

Since, ARM64 being the only platform, which supports ACPI and would 
support _CCA=0. I can just put CONFIG_ARM64 then as Arnd and Rafael 
mentioned.

Thanks,
Suravee



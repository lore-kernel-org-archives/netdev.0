From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V2 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Wed, 6 May 2015 17:16:35 -0500
Message-ID: <554A92C3.7060606@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <3234610.3j3NfP3xpR@vostro.rjw.lan> <55499569.8060403@amd.com>
 <4573209.dHyztuCFMt@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>, <arnd@arndb.de>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4573209.dHyztuCFMt@vostro.rjw.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/6/2015 5:21 PM, Rafael J. Wysocki wrote:
>>>> > >>+	bool
>>>> > >>+
>>>> > >>+config ACPI_SUPPORT_CCA_ZERO
>>> > >
>>> > >I guess this means "we support devices that can DMA, but are not coherent".
>>> > >right?
>> >
>> >Yes, basically when _CCA=0.
> So what about
>
> 	ARCH_SUPPORT_CACHE_INCOHERENT_DMA

Since this is specific to ACPI _CCA, I just want to be clear with the 
naming.

> or something similar?
>
>>>> > >>+	bool
>>>> > >>+
>>>> > >>   config ACPI_SLEEP
>>>> > >>   	bool
>>>> > >>   	depends on SUSPEND || HIBERNATION
>>>> > >>diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
>>>> > >>index 4bf7559..a6feca4 100644
>>>> > >>--- a/drivers/acpi/acpi_platform.c
>>>> > >>+++ b/drivers/acpi/acpi_platform.c
>>>> > >>@@ -108,9 +108,11 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev)
>>>> > >>   	if (IS_ERR(pdev))
>>>> > >>   		dev_err(&adev->dev, "platform device creation failed: %ld\n",
>>>> > >>   			PTR_ERR(pdev));
>>>> > >>-	else
>>>> > >>+	else {
>>> > >
>>> > >Please add braces to both branches when making such changes (as per CodingStyle).
>>> > >
>> >
>> >OK.
>> >
>>>> > >>+		acpi_setup_device_dma(adev, &pdev->dev);
>>> > >
>>> > >Why do we need to do that here (for the second time)?
>> >
>> >Because we are calling:
>> >    acpi_create_platform_device()
>> >      |--> platform_device_register_device_full()
>> >        |-->platform_device_alloc()
>> >
>> >This creates platform_device, which allocate a new platform_device->dev.
>> >This is not the same as the original acpi_device->dev that was created
>> >during acpi_add_single_object(). So, we have to set up the device
>> >coherency again.
> Ah, so the second arg is different now.
>
> Well, in that case, why do we need to set it up for the adev's dev member?
>

Just for sanity, since I don't know if adev->dev will be referenced 
anywhere else. This way, it's consistent for all copied of struct device 
generated.

Lemme know if you think that is unnecessary.

Thanks,

Suravee

From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 06/10] amd-xgbe: Set DMA mask based on hardware
 register value
Date: Thu, 19 Mar 2015 12:40:05 -0500
Message-ID: <550B09F5.8000707@amd.com>
References: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
 <20150319171301.26446.71081.stgit@tlendack-t1.amdoffice.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CB046B5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0112.outbound.protection.outlook.com ([157.56.111.112]:17559
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752044AbbCSR4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:56:11 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB046B5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 12:32 PM, David Laight wrote:
> From: Tom Lendacky
>> The hardware supplies a value that indicates the DMA range that it
>> is capable of using. Use this value rather than hard-coding it in
>> the driver.
> ...
>> +	/* Translate the address width setting into actual number */
>> +	switch (hw_feat->dma_width) {
>> +	case 0:
>> +		hw_feat->dma_width = 32;
>> +		break;
>> +	case 1:
>> +		hw_feat->dma_width = 40;
>> +		break;
>> +	case 2:
>> +		hw_feat->dma_width = 48;
>> +		break;
>> +	}
>> +
>
> I see a glaring problem should the hardware ever return 3.

Except this version of the hardware can't return a 3 and any future
versions will have a different device tree id or ACPI id and won't
match this driver (or the driver will be updated at that point to
support the newer versions).  I could have it default to 32 if you
feel it's really needed, though.

Thanks,
Tom

>
> 	David
>

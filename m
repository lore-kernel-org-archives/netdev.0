From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe: Do not schedule napi until ready
Date: Wed, 25 Feb 2015 08:34:05 -0600
Message-ID: <54EDDD5D.1080009@amd.com>
References: <20150224164801.26035.17252.stgit@tlendack-t1.amdoffice.net>
 <20150224.232532.330751855755079647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0138.outbound.protection.outlook.com ([157.56.111.138]:56736
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753119AbbBYPH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 10:07:29 -0500
In-Reply-To: <20150224.232532.330751855755079647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2015 10:25 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Tue, 24 Feb 2015 10:48:01 -0600
>
>> It is possible that the ethernet device could not have been properly
>> shutdown when Linux begins executing, through firmware use for example.
>> Until the amd-xgbe module is loaded, interrupts associated with the
>> the device could be pending. Once the module is loaded and interrupts
>> are requested, the interrupt could fire right away. If napi support
>> has not been initialized then the poll function will be null and result
>> in a kernel panic when napi attempts to invoke the poll function. Add
>> a check to the interrupt routine to be sure napi has been initialized
>> before trying to schedule it.
>>
>> Also, move the napi enablement support to be a bit earlier during
>> startup and a bit later during shutdown to be certain napi support is
>> enabled while the device can perform DMA.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> This is not how you fix a problem like this.
>
> You should absolutely not request the IRQ for the device, nor should
> you enable NAPI, until the device and driver are both fully setup and
> able to process those events successfully.

Thanks for the feedback.  I'll rework the code/flow to not request the
IRQ until everything is ready.  Since the subject and description will
change quite a bit I'll just submit a new patch rather than a "v2."

Thanks,
Tom

>
> Trust me, you're not the first person to hit this kind of problem.
> :-)
>

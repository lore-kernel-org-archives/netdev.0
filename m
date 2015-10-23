From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe: Use wmb before updating current descriptor
 count
Date: Fri, 23 Oct 2015 08:35:52 -0500
Message-ID: <562A37B8.2090108@amd.com>
References: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
 <20151023.025943.873672852211823864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <christoffer.dall@linaro.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0073.outbound.protection.outlook.com ([65.55.169.73]:49874
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751636AbbJWNf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:35:59 -0400
In-Reply-To: <20151023.025943.873672852211823864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2015 04:59 AM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Wed, 21 Oct 2015 15:37:05 -0500
>
>> The code currently uses the lightweight dma_wmb barrier before updating
>> the current descriptor count. Under heavy load, the Tx cleanup routine
>> was seeing the updated current descriptor count before the updated
>> descriptor information. As a result, the Tx descriptor was being cleaned
>> up before it was used because it was not "owned" by the hardware yet,
>> resulting in a Tx queue hang.
>>
>> Using the wmb barrier insures that the descriptor is updated before the
>> descriptor counter preventing the Tx queue hang. For extra insurance,
>> the Tx cleanup routine is changed to grab the current decriptor count on
>> entry and uses that initial value in the processing loop rather than
>> trying to chase the current value.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> Tested-by: Christoffer Dall <christoffer.dall@linaro.org>
>
> Applied, thanks.

Hi David,

Can you queue this up for stable?  It is applicable to 4.1 and 4.2.

Thanks,
Tom

>

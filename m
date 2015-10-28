From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe: Fix race between access of desc and desc
 index
Date: Wed, 28 Oct 2015 08:48:36 -0500
Message-ID: <5630D234.3070600@amd.com>
References: <20151026221354.927.9237.stgit@tlendack-t1.amdoffice.net>
 <20151027.195007.1435133435434786670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0076.outbound.protection.outlook.com ([157.56.110.76]:5088
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751023AbbJ1Nso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 09:48:44 -0400
In-Reply-To: <20151027.195007.1435133435434786670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2015 09:50 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Mon, 26 Oct 2015 17:13:54 -0500
>
>> During Tx cleanup it's still possible for the descriptor data to be
>> read ahead of the descriptor index. A memory barrier is required between
>> the read of the descriptor index and the start of the Tx cleanup loop.
>> This allows a change to a lighter-weight barrier in the Tx transmit
>> routine just before updating the current descriptor index.
>>
>> Since the memory barrier does result in extra overhead on arm64, keep
>> the previous change to not chase the current descriptor value. This
>> prevents the execution of the barrier for each loop performed.
>>
>> Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> Applied, thanks.
>

Thanks David.  Could you queue this up for the 4.1 and 4.2 stable
trees?

Thanks,
Tom

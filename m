From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/6] gianfar: Replace sysfs stubs with module
 params (fix)
Date: Mon, 17 Feb 2014 12:20:52 +0200
Message-ID: <5301E284.3080309@freescale.com>
References: <1392379445-28358-1-git-send-email-claudiu.manoil@freescale.com>	<1392379445-28358-3-git-send-email-claudiu.manoil@freescale.com> <20140216.234843.10302057405564080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe002.messaging.microsoft.com ([216.32.180.185]:14498
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751594AbaBQKVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:21:05 -0500
In-Reply-To: <20140216.234843.10302057405564080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/17/2014 6:48 AM, David Miller wrote:
> From: Claudiu Manoil <claudiu.manoil@freescale.com>
> Date: Fri, 14 Feb 2014 14:04:01 +0200
>
>> Removing the sysfs stubs for the Tx FIFOCFG and ATTRELI
>> (stashing) config registers, as these registers may only
>> be configured after a MAC reset, with the controller stopped
>> (i.e. during hw init, at probe() time). The current sysfs
>> stubs allow on-the-fly updates of these registers (the locking
>> measures are useless and only add unecessary code).
>>
>> Changing these registers on-the-fly is strogly discouraged.
>> In this regard, this patch may be seen as a security fix.
>>
>> To address this issue and not lose entirely these config
>> params, they are now accessible as driver module parameters,
>> and their names and default values have been preserved.
>>
>> Moreover, the stasing configuration options were effectively
>> disabled (didn't get to the hw anyway if changed) because
>> the stashing device_flags (HAS_BD_STASHING|HAS_BUF_STASHING)
>> were "accidentally" cleared during probe(). The patch fixes
>> this bug as well.
>>
>> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>
> Sorry, no new module parameters.
>
> And as you state these never actually reached the hardware so they
> _never worked_.  Please just remove them.
>
>

Sounds reasonable.
Only the stashing parameters (ATTRELI) didn't reach the HW.
The FIFO cfg ones did, but changing these defaults is also
discouraged (as documented in gianfar.txt).
Will send a V2.

Thanks.
Claudiu

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [RFC net-next 3/4] gianfar: Separate out the Rx and Tx coalescing
 functions
Date: Thu, 9 Aug 2012 19:24:48 +0300
Message-ID: <5023E450.9090704@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-4-git-send-email-claudiu.manoil@freescale.com> <20120808154454.GA11043@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:6561
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753072Ab2HIQZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 12:25:02 -0400
In-Reply-To: <20120808154454.GA11043@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/2012 6:44 PM, Paul Gortmaker wrote:
> [[RFC net-next 3/4] gianfar: Separate out the Rx and Tx coalescing functions] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
>
>> Split the coalescing programming support by Rx and Tx h/w queues, in order to
>> introduce a separate NAPI for the Tx confirmation path (next patch). This way,
>> the Rx processing path will handle the coalescing settings for the Rx queues
>> only, resp. the Tx confirmation processing path will handle the Tx queues.
>>
>> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>> ---
>>   drivers/net/ethernet/freescale/gianfar.c |   36 +++++++++++++++++++++++------
>>   1 files changed, 28 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
>> index ddd350a..919acb3 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.c
>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>> @@ -1794,8 +1794,8 @@ void gfar_start(struct net_device *dev)
>>   	dev->trans_start = jiffies; /* prevent tx timeout */
>>   }
>>
>> -void gfar_configure_coalescing(struct gfar_private *priv,
>> -			       unsigned long tx_mask, unsigned long rx_mask)
>> +static inline void gfar_configure_tx_coalescing(struct gfar_private *priv,
>
> I believe the preference is to not specify inline when all the chunks in
> play are present in the one C file -- i.e. let gcc figure it out.  Same
> for the Rx instance below.
>
> P.
> --
I agree with you.
thanks

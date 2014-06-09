From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH 1/2] net: sh_eth: Fix receive packet "exceeded" condition
 in sh_eth_rx()
Date: Mon, 9 Jun 2014 20:11:54 +0900
Message-ID: <5395967A.7030007@renesas.com>
References: <53958ED5.8070108@renesas.com> <53959359.1060407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:61680 "EHLO
	relmlie1.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932731AbaFILMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 07:12:01 -0400
In-Reply-To: <53959359.1060407@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2014/06/09 19:58), Sergei Shtylyov wrote:
> Hello.
> 
> On 09-06-2014 14:39, Yoshihiro Shimoda wrote:
> 
>> This patch fixes the packet "exceeded" condition in sh_eth_rx() when
>> RACT in an RX descriptor is not set and the "quota" is 0.
>> Otherwise, kernel panic happens because the "&n->poll_list" is deleted
>> twice in sh_eth_poll() which calls napi_complete() and net_rx_action().
> 
>> Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c |    8 +++-----
>>   1 file changed, 3 insertions(+), 5 deletions(-)
> 
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index 08ed9a3..ad0b5bd 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -1508,7 +1506,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
>>           sh_eth_write(ndev, EDRRR_R, EDRRR);
>>       }
>>
>> -    return exceeded;
>> +    return (*quota <= 0);
> 
>    Parens not needed here.

Thank you for the point. I will remove the parens.

Best regards,
Yoshihiro Shimoda

> WBR, Sergei
> 

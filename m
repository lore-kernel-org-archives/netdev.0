From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: TX Buffer incorrectly
 initialized
Date: Tue, 26 Mar 2013 12:12:54 -0400 (EDT)
Message-ID: <20130326.121254.2235859772172542379.davem@davemloft.net>
References: <y>
	<1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
	<1364312644.1716.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim_baxter@mentor.com, Frank.Li@freescale.com,
	fabio.estevam@freescale.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094Ab3CZQM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:12:57 -0400
In-Reply-To: <1364312644.1716.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Mar 2013 08:44:04 -0700

> On Tue, 2013-03-26 at 15:25 +0000, Jim Baxter wrote:
>> The TX Buffer in fec_enet_alloc_buffers was being initialized
>> with the receive register define BD_ENET_RX_INT instead of
>> the transmit register define BD_ENET_TX_INT
>> 
>> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
>> ---
>>  drivers/net/ethernet/freescale/fec_main.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>> index 3eb608f..2b78a1e 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -1391,7 +1391,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
>>  
>>  		if (fep->bufdesc_ex) {
>>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
>> -			ebdp->cbd_esc = BD_ENET_RX_INT;
>> +			ebdp->cbd_esc = BD_ENET_TX_INT;
>>  		}
>>  
>>  		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> 
> I am curious. What is the point having cbd_esc ?
> 
> Its a written only field.

It's read by the chip and this is how the chip decides what interrupts
to generate when the descriptor is fully processed.

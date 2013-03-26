From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next 1/1] net: fec: TX Buffer incorrectly initialized
Date: Tue, 26 Mar 2013 16:00:55 +0000
Message-ID: <5151C637.9010403@mentor.com>
References: <y> <1364311507-7489-1-git-send-email-jim_baxter@mentor.com> <1364312644.1716.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:41317 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965566Ab3CZQA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:00:58 -0400
Received: from svr-orw-fem-01.mgc.mentorg.com ([147.34.98.93])
	by relay1.mentorg.com with esmtp
	id 1UKWJ0-0006YP-Ax from Jim_Baxter@mentor.com
	for netdev@vger.kernel.org; Tue, 26 Mar 2013 09:00:58 -0700
In-Reply-To: <1364312644.1716.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The field is the extended status control for the FEC network device, the
values written to it are used to set the hardware transmit and receive
state.
*From:* Eric Dumazet (eric.dumazet@gmail.com) *Sent:* Tue, 26 Mar 2013
08:44:04 -0700 *To:* jim_baxter@mentor.com *Cc:* davem@davemloft.net,
Frank.Li@freescale.com, fabio.estevam@freescale.com,
netdev@vger.kernel.org *Subject:* Re: [PATCH net-next 1/1] net: fec: TX
Buffer incorrectly initialized
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
> 
> 
> 

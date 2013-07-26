From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Fri, 26 Jul 2013 09:35:03 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <20130725090352.574b874d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Stephen Hemminger <stephen@networkplumber.org>,
	=?iso-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:8090 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755678Ab3GZJfI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 05:35:08 -0400
In-Reply-To: <20130725090352.574b874d@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fir, 26 Jul 2013 12:04, Stephen Hemminger wrote:
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c 
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index 0642006..631bd5a 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -280,11 +280,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>  	unsigned short	status;
>>  	unsigned int index;
>>  
>> -	if (!fep->link) {
>> -		/* Link is down or auto-negotiation is in progress. */
>> -		return NETDEV_TX_BUSY;
>> -	}
>> -
>
>That is a bug anyway. Since it would cause spin loop in transmit code (even without -rt).
>If the driver cared to test it (most drivers just let hardware deal with this situation),
>then it should free packet and return TX_OK.

When link is down, the logic is
	- call netif_stop_queue() to stop queue
	- and then notify there have no link using netif_carrier_off().

But the flow must be handled in fec_enet_adjust_link() function, not in xmit().


Thanks,
Andy

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 1/1] net: fec: Fix Transmitted bytes counter
Date: Mon, 01 Jul 2013 13:40:00 -0700 (PDT)
Message-ID: <20130701.134000.477493946784788761.davem@davemloft.net>
References: <Jim_Baxter_<jim_baxter@mentor.com>
	<1372357508-23038-1-git-send-email-jim_baxter@mentor.com>
	<9848F2DB572E5649BA045B288BE08FBE01508FB2@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim_baxter@mentor.com, r49496@freescale.com, B20596@freescale.com,
	shawn.guo@linaro.org, netdev@vger.kernel.org
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab3GAUkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:40:01 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE01508FB2@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Fugang-B38611 <B38611@freescale.com>
Date: Fri, 28 Jun 2013 02:11:30 +0000

> On 06/28/13 02:25, Jim Baxter wrote:
> 
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>> index ed6180e..05a5f76 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -738,6 +738,7 @@ fec_enet_tx(struct net_device *ndev)
>>  				ndev->stats.tx_carrier_errors++;
>>  		} else {
>>  			ndev->stats.tx_packets++;
>> +			ndev->stats.tx_bytes += bdp->cbd_datlen;
>>  		}
>>  
>>  		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
>> --
> You cannot stat. tx_bytes in here, since stat.tx_bytes indicate that all bytes sent by MAC regardless whether there have error packets or not.
> You must add the stat. at xmit function as below:

I completely disagree.

tx_bytes indicates what actually made it to the wires, so Jim's original
patch is the correct one.

Every single driver I have ever written, always increments tx_bytes in
the transmit completion handler, not when the device layer gives the
packet to the driver.

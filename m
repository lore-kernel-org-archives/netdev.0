From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net v1 1/1] net: fec: Fix Transmitted bytes counter
Date: Tue, 2 Jul 2013 09:32:31 +0100
Message-ID: <51D2901F.7040503@mentor.com>
References: <Jim_Baxter_<jim_baxter@mentor.com> <1372357508-23038-1-git-send-email-jim_baxter@mentor.com> <9848F2DB572E5649BA045B288BE08FBE01508FB2@039-SN2MPN1-023.039d.mgd.msft.net> <20130701.134000.477493946784788761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <B38611@freescale.com>, <r49496@freescale.com>,
	<B20596@freescale.com>, <shawn.guo@linaro.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:65156 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab3GBIci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 04:32:38 -0400
In-Reply-To: <20130701.134000.477493946784788761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/13 21:40, David Miller wrote:
> From: Duan Fugang-B38611 <B38611@freescale.com>
> Date: Fri, 28 Jun 2013 02:11:30 +0000
> 
>> On 06/28/13 02:25, Jim Baxter wrote:
>>
>>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>>> index ed6180e..05a5f76 100644
>>> --- a/drivers/net/ethernet/freescale/fec_main.c
>>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>>> @@ -738,6 +738,7 @@ fec_enet_tx(struct net_device *ndev)
>>>  				ndev->stats.tx_carrier_errors++;
>>>  		} else {
>>>  			ndev->stats.tx_packets++;
>>> +			ndev->stats.tx_bytes += bdp->cbd_datlen;
>>>  		}
>>>  
>>>  		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
>>> --
>> You cannot stat. tx_bytes in here, since stat.tx_bytes indicate that all bytes sent by MAC regardless whether there have error packets or not.
>> You must add the stat. at xmit function as below:
> 
> I completely disagree.
> 
> tx_bytes indicates what actually made it to the wires, so Jim's original
> patch is the correct one.
> 
> Every single driver I have ever written, always increments tx_bytes in
> the transmit completion handler, not when the device layer gives the
> packet to the driver.
> 

If this should be the first version of the patch, can I cancel the
second version and set the first version to new in patchwork, or is it
best to submit a third version?

Thank you,
Jim

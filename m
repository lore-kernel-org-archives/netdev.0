From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/8] vxlan: Factor out vxlan send api.
Date: Sun, 23 Jun 2013 18:45:14 -0700 (PDT)
Message-ID: <20130623.184514.1432951068531783628.davem@davemloft.net>
References: <1371713207-8232-1-git-send-email-pshelar@nicira.com>
	<OF9BEEA27A.EA477839-ON87257B90.0045D6A5-85257B90.00463241@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab3FXBpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 21:45:14 -0400
In-Reply-To: <OF9BEEA27A.EA477839-ON87257B90.0045D6A5-85257B90.00463241@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 20 Jun 2013 08:46:42 -0400

>> From: Pravin B Shelar <pshelar@nicira.com>
>  
> 
>> @@ -1205,13 +1222,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff
>> *skb, struct net_device *dev)
>> 
>>        skb1 = skb_clone(skb, GFP_ATOMIC);
>>        if (skb1) {
>> -         rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
>> +         rc1 = __vxlan_xmit(skb1, dev, rdst, did_rsc);
>>           if (rc == NETDEV_TX_OK)
>>              rc = rc1;
>>        }
>>     }
>> 
>> -   rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
>> +   rc1 = __vxlan_xmit(skb, dev, rdst0, did_rsc);
>>     if (rc == NETDEV_TX_OK)
>>        rc = rc1;
>>     return rc;
> 
> You're changing the name of the function that sends a
> packet to one destination because you think "__vxlan_xmit"
> is more descriptive than "vxlan_xmit_one" ?

Agreed, this is rediculous.

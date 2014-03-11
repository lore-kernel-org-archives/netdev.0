From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of
 kfree_skb.
Date: Tue, 11 Mar 2014 00:42:17 -0400 (EDT)
Message-ID: <20140311.004217.1616529960369263682.davem@davemloft.net>
References: <871ty9qvaf.fsf_-_@xmission.com>
	<87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbaCKEmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 00:42:19 -0400
In-Reply-To: <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Mar 2014 20:44:27 -0700

> On Mon, 2014-03-10 at 20:18 -0700, Eric W. Biederman wrote:
>> -			consume_skb(skb);
>> +			dev_consume_skb_any(skb);
> 
> Why is this needed ? AFAIK we run in softirq here.
> 
>>  			return ret;
>>  		}
>>  	}
>> @@ -1132,7 +1132,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>>  
>>  		if (unlikely(skb_cow_head(skb,
>>  					  skb->data - skb_mac_header(skb)))) {
>> -			kfree_skb(skb);
>> +			dev_kfree_skb_any(skb);
> 
> same here.

These changes eminate from a recent discussion about netpoll, which can
call into the driver from hardware interrupts, particularly when netconsole
services a printk from hardware interrupt context.

bnx2x already makes similar ammends.

I hope that Eric B. here audited to make sure he's only doing this
transformation in situations that actually need this treatment for
the above mentioned issue.

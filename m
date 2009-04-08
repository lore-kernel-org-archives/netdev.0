From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 08 Apr 2009 16:15:15 -0700 (PDT)
Message-ID: <20090408.161515.40986410.davem@davemloft.net>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	<20090408160948.2257d311@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754169AbZDHXPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 19:15:25 -0400
In-Reply-To: <20090408160948.2257d311@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 8 Apr 2009 16:09:48 -0700

> On Wed, 8 Apr 2009 15:48:12 -0700
> Tom Herbert <therbert@google.com> wrote:
> 
>> -extern int		netif_receive_skb(struct sk_buff *skb);
>> +extern int            __netif_receive_skb(struct sk_buff *skb);
>> +
>> +static inline int netif_receive_skb(struct sk_buff *skb)
>> +{
>> +#ifdef CONFIG_NET_SOFTRPS
>> +	return netif_rx(skb);
>> +#else
>> +	return __netif_receive_skb(skb);
>> +#endif
>> +}
> 
> Ugh, this forces all devices receiving back into a single backlog
> queue.

Yes, it basically turns off NAPI.

This patch seems to be throwing the baby out with the
bath water.

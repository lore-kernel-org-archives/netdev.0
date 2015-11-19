From: subashab@codeaurora.org
Subject: Re: WARN due to local_bh_disable called with interrupts disabled
Date: Thu, 19 Nov 2015 22:19:21 -0000
Message-ID: <3ffdb703b1c0b9011665e0d81e3e62c2.squirrel@www.codeaurora.org>
References: <94ad7f112d565984ffdc4aaafe002803.squirrel@www.codeaurora.org>
    <20151119114208.3b8e67c3@redhat.com>
    <1447936112.22599.197.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jesper Dangaard Brouer" <brouer@redhat.com>,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37434 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933993AbbKSWTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:19:22 -0500
In-Reply-To: <1447936112.22599.197.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> The call gic_handle_irq() sounds like a hardware IRQ func/context.
>>
>> The flush_backlog() call is due to the device is being unregistered.
>>

Yes, this is the ARM interrupt controller. It appeared as if wifi was
getting torn down around this.

>> I'm surprised to see kfree_skb() being called from hardirq context, I
>> though that was not allowed.
>>
>> AFAIK this is the reason we have: __dev_kfree_skb_any() which defer
>> freeing the SKB if (in_irq() || irqs_disabled()).
>>
>> Code:
>>  void __dev_kfree_skb_any(struct sk_buff *skb, enum skb_free_reason
>> reason)
>>  {
>> 	if (in_irq() || irqs_disabled())
>> 		__dev_kfree_skb_irq(skb, reason);
>> 	else
>> 		dev_kfree_skb(skb);
>>  }
>
> Right, but flush_backlog() is processing packets coming from RX, that
> should have no conntracking attached at all.
>
> Might be a bug in a tunnel ?

Thanks Jesper \ Eric. I'll explore into why a conntrack entry is
associated with this skb.

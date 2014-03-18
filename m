From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 10:53:01 -0700
Message-ID: <87fvmf75s2.fsf@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
	<1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53213 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757289AbaCRRxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:53:08 -0400
In-Reply-To: <1395149407.22343.8.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Tue, 18 Mar 2014 13:30:07 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> writes:

> On Mon, 2014-03-17 at 23:27 -0700, Eric W. Biederman wrote:
> [...]
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -554,14 +554,21 @@ static void kfree_skbmem(struct sk_buff *skb)
>>  
>>  static void skb_release_head_state(struct sk_buff *skb)
>>  {
>> +	WARN_ONCE(in_irq() && !skb_irq_freeable(skb),
>> +		  "%s called from irq! sp %d nfct %d frag_list %d %pF dst %lx",
>> +		  __func__,
>> +		  IS_ENABLED(CONFIG_XFRM) ? !!skb->sp : 0,
>> +		  IS_ENABLED(CONFIG_NF_CONNTRACK) ? !!skb->nfct : 0,
> [...]
>
> This is a syntax error if CONFIG_XFRM or CONFIG_NF_CONNTRACK is
> disabled; you have to use #ifdef's.

Doh!

That if nothing else definitely calls for a respin of this patch.

Eric

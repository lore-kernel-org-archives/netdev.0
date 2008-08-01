From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net_sched: Add qdisc __NET_XMIT_STOLEN flag
Date: Fri, 1 Aug 2008 07:58:32 +0000
Message-ID: <20080801075832.GB5158@ff.dom.local>
References: <20080731171431.GA9464@ami.dom.local> <4892AA16.40706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:62386 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbYHAHxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 03:53:16 -0400
Received: by ug-out-1314.google.com with SMTP id h2so460542ugf.16
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2008 00:53:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4892AA16.40706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2008 at 08:15:50AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Hi,
>>
>> Here is a complete, I hope,  version of the patch to not linger this
>> all to much, but of course any redoing is possible.
>
> This looks good to me. Just one suggestion:
>
>> +#ifdef CONFIG_NET_CLS_ACT
>> +/* additional qdisc xmit flags */
>> +enum net_xmit_qdisc_t {
>> +	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
>> +};
>> +
>> +#define net_xmit_drop_count(e)	((e) & __NET_XMIT_STOLEN ? 0 : 1)
>> +
>> +#else
>> +#define net_xmit_drop_count(e)	(1)
>> +#endif
>> +
>>  static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  {
>>  #ifdef CONFIG_NET_SCHED
>> @@ -343,7 +355,7 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
>>  {
>>  	qdisc_skb_cb(skb)->pkt_len = skb->len;
>> -	return qdisc_enqueue(skb, sch);
>> +	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
>
> It would be nice to handle NET_XMIT_BYPASS similar, currently its
> mapped to NET_XMIT_SUCCESS by dev_queue_xmit(). Simply adding it
> to net_xmit_qdisc_t as
>
> __NET_XMIT_BYPASS = NET_XMIT_MASK + 0x2
>
> and removing the mapping from dev_queue_xmit() should work I think.

OK, I think, I'll prepare a separate patch for this.

Thanks,
Jarek P.

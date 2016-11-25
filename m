From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net/arp: ARP cache aging failed.
Date: Fri, 25 Nov 2016 14:53:43 +0100
Message-ID: <40b84d35-4185-bfbc-7f85-9d6abf984d31@stressinduktion.org>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
 <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
 <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
 <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
 <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg>
 <c82b7b44-c0ad-9ee7-1114-3eae3b5cf75a@huawei.com>
 <1fdf938e-600c-ce58-ece1-06b816ddba1c@stressinduktion.org>
 <alpine.LFD.2.11.1611250957100.1966@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: YueHaibing <yuehaibing@huawei.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36829 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754708AbcKYODl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 09:03:41 -0500
In-Reply-To: <alpine.LFD.2.11.1611250957100.1966@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.11.2016 09:18, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 24 Nov 2016, Hannes Frederic Sowa wrote:
> 
>> I think some people are thinking about it already (me also ;) ).
>>
>> But it is not easy to come up with a solution. First of all, we need to
>> look up the L2 address again in the neighbor cache and confirm the
>> appropriate neighbor. Secondly we should only do that for packets which
>> we can actually confirm (that means passing the TCP recv tests or some
>> other kind of confirmation besides simply spamming the box etc). Also it
>> needs to be fast.
> 
> 	Another option would be to add similar bit to
> struct sock (sk_dst_pending_confirm), may be ip_finish_output2
> can propagate it to dst_neigh_output via new arg and then to
> reset it.

I don't understand how this can help? Maybe I understood it wrong?

> Or to change n->confirmed via some new inline sock
> function instead of changing dst_neigh_output. At this place 
> skb->sk is optional, may be we need (skb->sk && dst ==
> skb->sk->sk_dst_cache) check. Also, when sk_dst_cache changes
> we should clear this flag.

In "(skb->sk && dst == skb->sk->sk_dst_cache)" where does dst come from?

I don't see a possibility besides using mac_header or inner_mac_header
to look up the incoming MAC address and confirm that one in the neighbor
cache so far (we could try to optimize this case for rt_gateway though).

Bye,
Hannes

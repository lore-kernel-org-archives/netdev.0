From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net/arp: ARP cache aging failed.
Date: Fri, 25 Nov 2016 10:18:40 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1611250957100.1966@ja.home.ssi.bg>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com> <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg> <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com> <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
 <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg> <c82b7b44-c0ad-9ee7-1114-3eae3b5cf75a@huawei.com> <1fdf938e-600c-ce58-ece1-06b816ddba1c@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YueHaibing <yuehaibing@huawei.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50036 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751368AbcKYITI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 03:19:08 -0500
In-Reply-To: <1fdf938e-600c-ce58-ece1-06b816ddba1c@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 24 Nov 2016, Hannes Frederic Sowa wrote:

> I think some people are thinking about it already (me also ;) ).
> 
> But it is not easy to come up with a solution. First of all, we need to
> look up the L2 address again in the neighbor cache and confirm the
> appropriate neighbor. Secondly we should only do that for packets which
> we can actually confirm (that means passing the TCP recv tests or some
> other kind of confirmation besides simply spamming the box etc). Also it
> needs to be fast.

	Another option would be to add similar bit to
struct sock (sk_dst_pending_confirm), may be ip_finish_output2
can propagate it to dst_neigh_output via new arg and then to
reset it. Or to change n->confirmed via some new inline sock
function instead of changing dst_neigh_output. At this place 
skb->sk is optional, may be we need (skb->sk && dst ==
skb->sk->sk_dst_cache) check. Also, when sk_dst_cache changes
we should clear this flag.

Regards

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink broadcast return value
Date: Thu, 12 Feb 2009 13:45:58 +0100
Message-ID: <49941A06.6050006@trash.net>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org> <4992C827.20302@trash.net> <4992FF51.9010507@netfilter.org> <499302E0.4070406@trash.net> <49933CBE.8010108@netfilter.org> <4993AE94.1000104@trash.net> <499417E3.5010304@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48977 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759270AbZBLMqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 07:46:04 -0500
In-Reply-To: <499417E3.5010304@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> So you're returning an error when at least one of the "reliable"
>> sockets doesn't get its delivery.
> 
> Patrick, I like it, I'm fine with this approach as soon as it let me add
> the "reliable" ctnetlink state-change reporting. I can add the following
> on top of the patch that David already applied:
> 
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> [...]
> @@ -999,6 +1000,7 @@ static inline int do_one_broadcast(struct sock *sk,
>  		p->skb2 = NULL;
>  	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
>  		netlink_overrun(sk);
> +		p->delivery_failure = 1;
>                 ^^^^^^^^^^^^^^^^^^^^^^^^
> Replace this by:
> +		if (nlk->flags & NETLINK_HIGHLY_RELIABLE)
> +			p->delivery_failure = 1;
> 
> And include the flag definition and setsockopt() operations in the new
> patch, of course.

Sounds good. Maybe a nicer name for the flag :)

> Please, find the previous patch that was applied to net-next tree
> enclosed to save you some time in case that you don't know what patch I
> was refering to. I think that the changes (several drivers and such) are
> still useful, as they should ignore the return value of
> netlink_broadcast() since it's not of any use for them (as we already
> discussed, they printk the error, that's useless).

Agreed. The remaining question would be what to do about
xfrm_state. I think it can stay as it is if you add this
flag, *swan could use it if desired.



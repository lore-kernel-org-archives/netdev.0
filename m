From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC] netlink broadcast return value
Date: Thu, 12 Feb 2009 13:41:22 +0100
Message-ID: <499418F2.8070008@netfilter.org>
References: <4985A4C5.4050908@netfilter.org> <20090202.140533.121159038.davem@davemloft.net> <49903B03.2040302@trash.net> <4990B38A.3020207@netfilter.org> <4990BADA.7040309@trash.net> <4990C337.3040704@netfilter.org> <4991863F.3030800@trash.net> <4991CCC1.7080308@netfilter.org> <4992C827.20302@trash.net> <4992FF51.9010507@netfilter.org> <499302E0.4070406@trash.net> <49933CBE.8010108@netfilter.org> <4993AE94.1000104@trash.net> <499417E3.5010304@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499417E3.5010304@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
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

Oh, and also for this:

> 	if (p->skb2 == NULL) {
> 		netlink_overrun(sk);
> 		/* Clone failed. Notify ALL listeners. */
> 		p->failure = 1;
                ^^^^^^^^^^^^^^^

if (nlk->flags & NETLINK_HIGHLY_RELIABLE)
	p->failure = 1;

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers

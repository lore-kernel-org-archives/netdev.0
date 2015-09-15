From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Tue, 15 Sep 2015 15:54:45 -0700
Message-ID: <CAF2d9jgb_MP==6Go-quk=9s_Nyg8ewgFzfkvUi-y5j_7zBqksw@mail.gmail.com>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:35781 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbIOWzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 18:55:05 -0400
Received: by ykdu9 with SMTP id u9so202721682ykd.2
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 15:55:05 -0700 (PDT)
In-Reply-To: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 3:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> If skb carries a l4 hash, no need to perform a flow dissection.
>
> Performance is slightly better :
>
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.39012e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.39393e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.39988e+06
>
> After patch :
>
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.43579e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.44304e+06
> lpaa5:~# ./super_netperf 200 -H lpaa6 -t TCP_RR -l 100
> 2.44312e+06
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_main.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 771a449..9250d1e 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3136,6 +3136,10 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
>         struct flow_keys flow;
>         u32 hash;
>
> +       if (bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP34 &&
> +           skb->l4_hash)
if (ENCAP34 || LAYER34) && l4_hash) may be?

>
> +                       return skb->hash;
> +
>         if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
>             !bond_flow_dissect(bond, skb, &flow))
>                 return bond_eth_hash(skb);
>
>

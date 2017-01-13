From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] flow disector: check if arp_eth is null rather than arp
Date: Fri, 13 Jan 2017 10:24:11 -0800
Message-ID: <1484331851.13165.46.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170113133428.20130-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Simon Horman <simon.horman@netronome.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>, Amir Vadai <amir@vadai.me>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34784 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdAMSc4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:32:56 -0500
In-Reply-To: <20170113133428.20130-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 13:34 +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> arp is being checked instead of arp_eth to see if the call to
> __skb_header_pointer failed. Fix this by checking arp_eth is
> null instead of arp.
> 
> CoverityScan CID#1396428 ("Logically dead code") on 2nd
> arp comparison (which should be arp_eth instead).
> 
> Fixes: commit 55733350e5e8b70c5 ("flow disector: ARP support")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/core/flow_dissector.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index e3dffc7..fec48e9 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -409,7 +409,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>  					       sizeof(_arp_eth), data,
>  					       hlen - sizeof(_arp),
>  					       &_arp_eth);
> -		if (!arp)
> +		if (!arp_eth)
>  			goto out_bad;
>  
>  		if (dissector_uses_key(flow_dissector,

It looks that we try very hard to add critical bugs in flow dissector.

This is embarrassing really.

I am questioning if the __skb_header_pointer() is correct

Why using hlen - sizeof(_arp) ?

               arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
                                              sizeof(_arp_eth), data,
                                              hlen - sizeof(_arp),
                                              &_arp_eth);

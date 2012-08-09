From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Thu, 09 Aug 2012 16:38:51 -0700 (PDT)
Message-ID: <20120809.163851.1182547052663187702.davem@davemloft.net>
References: <1344523833.28967.996.camel@edumazet-glaptop>
	<CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw@mail.gmail.com>
	<1344547743.31104.582.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, paul@paul-moore.com, casey@schaufler-ca.com,
	johnstul@us.ibm.com, serge@hallyn.com,
	linux-kernel@vger.kernel.org, james.l.morris@oracle.com,
	selinux@tycho.nsa.gov, john.johansen@canonical.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344547743.31104.582.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Aug 2012 23:29:03 +0200

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 76dde25..ec410e0 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1536,6 +1536,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
>  			  arg->csumoffset) = csum_fold(csum_add(nskb->csum,
>  								arg->csum));
>  		nskb->ip_summed = CHECKSUM_NONE;
> +		skb_orphan(nskb);
>  		skb_set_queue_mapping(nskb, skb_get_queue_mapping(skb));
>  		ip_push_pending_frames(sk, &fl4);
>  	}
> 

This is definitely the best fix, please submit this formally.

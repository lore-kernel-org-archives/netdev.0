From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] netfilter: ip_tables: remove useless variable
 assignment in get_info()
Date: Mon, 26 Jun 2017 19:46:58 -0700
Message-ID: <1498531618.24295.57.camel@perches.com>
References: <20170626223428.GA11614@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0132.hostedemail.com ([216.40.44.132]:57808 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751445AbdF0CrC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 22:47:02 -0400
In-Reply-To: <20170626223428.GA11614@embeddedgus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-06-26 at 17:34 -0500, Gustavo A. R. Silva wrote:
> Value assigned to variable _ret_ at line 970 is overwritten either at
> line 986 or 988, before it can be used. This makes such variable
> assignment useless.
> 
> Addresses-Coverity-ID: 1226932
[]
> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
[]
> @@ -967,7 +967,7 @@ static int get_info(struct net *net, void __user *user,
>  		struct xt_table_info tmp;
>  
>  		if (compat) {
> -			ret = compat_table_info(private, &tmp);
> +			compat_table_info(private, &tmp);

why isn't it more appropriate to test the return value?

>  			xt_compat_flush_offsets(AF_INET);
>  			private = &tmp;
>  		}

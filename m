From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] netlink: don't copy over empty attribute data
Date: Wed, 22 Oct 2014 08:55:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9DCF6A@AcuExch.aculab.com>
References: <1413924669-26732-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "a.ryabinin@samsung.com" <a.ryabinin@samsung.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"mschmidt@redhat.com" <mschmidt@redhat.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Sasha Levin' <sasha.levin@oracle.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413924669-26732-1-git-send-email-sasha.levin@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin
> netlink uses empty data to seperate different levels. However, we still
> try to copy that data from a NULL ptr using memcpy, which is an undefined
> behaviour.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  lib/nlattr.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/lib/nlattr.c b/lib/nlattr.c
> index 9c3e85f..6512b43 100644
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -430,7 +430,8 @@ void __nla_put(struct sk_buff *skb, int attrtype, int attrlen,
>  	struct nlattr *nla;
> 
>  	nla = __nla_reserve(skb, attrtype, attrlen);
> -	memcpy(nla_data(nla), data, attrlen);
> +	if (data)
> +		memcpy(nla_data(nla), data, attrlen);

Were it even appropriate to add a conditional here, the correct
check would be against 'attrlen', not 'data'.

	David

>  }
>  EXPORT_SYMBOL(__nla_put);
> 
> --
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

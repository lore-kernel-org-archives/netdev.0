From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6 NET] Fix ifmap alignment issues over rtnetlink
Date: Wed, 22 Sep 2004 12:18:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C9wiC-0003gJ-00@gondolin.me.apana.org.au>
References: <20040921224127.GM566@postel.suug.ch>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20040921224127.GM566@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
> @@ -277,6 +277,9 @@
>                dev_change_flags(dev, ifm->ifi_flags);
> 
>        if (ida[IFLA_MAP - 1]) {
> +               struct rtnl_link_ifmap *u_map;
> +               struct ifmap k_map;
> +
>                if (!dev->set_config) {
>                        err = -EOPNOTSUPP;
>                        goto out;
> @@ -287,11 +290,19 @@

<snipped>

> +               err = dev->set_config(dev, (struct ifmap *) &k_map);

What's this cast for?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

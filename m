From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Fri, 17 Sep 2004 22:40:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C8I2m-0005BS-00@gondolin.me.apana.org.au>
References: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
>
> ChangeSet@1.1925, 2004-09-17 20:13:22+09:00, yoshfuji@linux-ipv6.org
> [IPV4] replace ip_route_output_key() with ip_route_output_flow().
> 
> Since ip_route_output_key() is identical to ip_route_output_flow(),
> except for the lack of the sk and the flags arguments, 
> let's use the later generic one.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> diff -Nru a/net/atm/clip.c b/net/atm/clip.c
> --- a/net/atm/clip.c    2004-09-17 20:14:58 +09:00
> +++ b/net/atm/clip.c    2004-09-17 20:14:58 +09:00
> @@ -556,7 +556,7 @@
>                unlink_clip_vcc(clip_vcc);
>                return 0;
>        }
> -       error = ip_route_output_key(&rt,&fl);
> +       error = ip_route_output_flow(&rt, &fl, NULL, 0);

Yuck.  You've bloated the source as well as the binary for the sake
of deleting one function.

Please provide ip_route_output_key() as an inline wrapper around
ip_route_output_flow() so that its users don't have to change.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

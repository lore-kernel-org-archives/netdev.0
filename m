From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] ipv6: do not delete previously existing ECMP
 routes if add fails
Date: Wed, 13 May 2015 14:28:57 +0200
Message-ID: <55534389.8070307@6wind.com>
References: <cover.1431500953.git.mkubecek@suse.cz> <4e3d075f2be93d9655bc1372a107584368a29eab.1431500953.git.mkubecek@suse.cz>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4e3d075f2be93d9655bc1372a107584368a29eab.1431500953.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/05/2015 11:50, Michal Kubecek a =C3=A9crit :
> If adding a nexthop of an IPv6 multipath route fails, comment in
> ip6_route_multipath() says we are going to delete all nexthops alread=
y
> added. However, current implementation deletes even the routes it
> hasn't even tried to add yet. For example, running
>
>    ip route add 1234:5678::/64 \
>        nexthop via fe80::aa dev dummy1 \
>        nexthop via fe80::bb dev dummy1 \
>        nexthop via fe80::cc dev dummy1
>
> twice results in removing all routes first command added.
>
> Limit the second (delete) run to nexthops that succeeded in the first
> (add) run.
>
> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP=
)")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>   net/ipv6/route.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index d3588885f097..18b92c05b541 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2536,6 +2536,7 @@ beginning:
>   				 * next hops that have been already added.
>   				 */
>   				add =3D 0;
> +				remaining =3D cfg->fc_mp_len - remaining;
>   				goto beginning;
Not sure to understand your fix. At the label beginning, the code is:

beginning:
         rtnh =3D (struct rtnexthop *)cfg->fc_mp;
         remaining =3D cfg->fc_mp_len;

Hence, 'remaining' will be overridden. How does your patch work?

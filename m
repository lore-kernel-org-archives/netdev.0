From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: simplify a
 br_multicast_query_received() function call
Date: Wed, 23 Apr 2014 14:47:48 -0400 (EDT)
Message-ID: <20140423.144748.1259564888396787227.davem@davemloft.net>
References: <1398106775-14857-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1398106775-14857-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@web.de>
Date: Mon, 21 Apr 2014 20:59:35 +0200

> The call from the IPv6 part can be simplified as the beginning of the=

> calling function ensures that we end up here when having a proper IPv=
6
> source address only.
> =

> Introduced by 6565b9eeef194afbb3beec80d6dd2447f4091f8c
> ("bridge: multicast: add sanity check for query source addresses")
> =

> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>
> ---
>  net/bridge/br_multicast.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> =

> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 7b757b5..d2c3aae 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1282,8 +1282,7 @@ static int br_ip6_multicast_query(struct net_br=
idge *br,
>  		goto out;
>  	}
>  =

> -	br_multicast_query_received(br, port, &br->ip6_querier,
> -				    !ipv6_addr_any(&ip6h->saddr),
> +	br_multicast_query_received(br, port, &br->ip6_querier, 1,
>  				    is_general_query, max_delay);
>  =

>  	if (!group)

This doesn't make any sense to me, is_general_query can be false at thi=
s
point.

Furthermore, even if your change would be correct, the argument is a
boolean not an integer.

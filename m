From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [PATCH net] bridge: fix br_multicast_query_expired()
	bug
Date: Thu, 28 May 2015 09:06:45 -0300
Message-ID: <20150528120645.GA1233@indiana.gru.redhat.com>
References: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "Steinar H. Gunderson" <sesse@samfundet.no>,
	netdev <netdev@vger.kernel.org>, bridge@lists.linux-foundation.org,
	Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
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

On Thu, May 28, 2015 at 04:42:54AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> br_multicast_query_expired() querier argument is a pointer to
> a struct bridge_mcast_querier :
>=20
> struct bridge_mcast_querier {
>         struct br_ip addr;
>         struct net_bridge_port __rcu    *port;
> };
>=20
> Intent of the code was to clear port field, not the pointer to querier.
>=20
> Fixes: 2cd4143192e8 ("bridge: memorize and export selected IGMP/MLD que=
rier port")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Linus L=C3=BCssing <linus.luessing@web.de>
> Cc: Steinar H. Gunderson <sesse@samfundet.no>
> ---
>  net/bridge/br_multicast.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index a3abe6ed111e..22fd0419b314 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1822,7 +1822,7 @@ static void br_multicast_query_expired(struct net=
_bridge *br,
>  	if (query->startup_sent < br->multicast_startup_query_count)
>  		query->startup_sent++;
> =20
> -	RCU_INIT_POINTER(querier, NULL);
> +	RCU_INIT_POINTER(querier->port, NULL);
>  	br_multicast_send_query(br, NULL, query);
>  	spin_unlock(&br->multicast_lock);
>  }
>=20
>=20
>=20
> --

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>

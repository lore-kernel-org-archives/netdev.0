From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: BH already disabled in br_fdb_cleanup()
Date: Mon, 16 Jan 2012 07:53:49 -0800
Message-ID: <20120116075349.2e9bf1e1@nehalam.linuxnetplumber.net>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
	<1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAGsizzJpdF5xzsEiZd5R0GD8r7pDJyz4ro=4vLBnonxfAVYg-Q@mail.gmail.com>
	<1326723932.2255.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326724550.2255.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?xaB0ZWZhbg==?= Gula <steweg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42270 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524Ab2APPxw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 10:53:52 -0500
In-Reply-To: <1326724550.2255.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jan 2012 15:35:50 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> br_fdb_cleanup() is run from timer interrupt, BH already masked.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: =C5=A0tefan Gula <steweg@gmail.com>
> ---
>  net/bridge/br_fdb.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index f963f6b..5ba0c84 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -146,7 +146,7 @@ void br_fdb_cleanup(unsigned long _data)
>  	unsigned long next_timer =3D jiffies + br->ageing_time;
>  	int i;
> =20
> -	spin_lock_bh(&br->hash_lock);
> +	spin_lock(&br->hash_lock);
>  	for (i =3D 0; i < BR_HASH_SIZE; i++) {
>  		struct net_bridge_fdb_entry *f;
>  		struct hlist_node *h, *n;
> @@ -162,7 +162,7 @@ void br_fdb_cleanup(unsigned long _data)
>  				next_timer =3D this_timer;
>  		}
>  	}
> -	spin_unlock_bh(&br->hash_lock);
> +	spin_unlock(&br->hash_lock);
> =20
>  	mod_timer(&br->gc_timer, round_jiffies_up(next_timer));
>  }
>=20
>=20

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

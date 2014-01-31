From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [RFC PATCH] net: core: move core networking work to power efficient
 workqueue
Date: Fri, 31 Jan 2014 01:48:37 +0100
Message-ID: <52EAF2E5.8090403@meshcoding.com>
References: <1391128402-10725-1-git-send-email-zoran.markovic@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="FgmjO4qw8O7x8rjEXkT6tBV3b3GrgqAVj"
Cc: netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Eric Dumazet <edumazet@google.com>,
	Julian Anastasov <ja@ssi.bg>, Flavio Leitner <fbl@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Patrick McHardy <kaber@trash.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amerigo Wang <amwang@redhat.com>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>,
	Simon Horman <horms@verge.net.au>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: Zoran Markovic <zoran.markovic@linaro.org>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391128402-10725-1-git-send-email-zoran.markovic@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FgmjO4qw8O7x8rjEXkT6tBV3b3GrgqAVj
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 31/01/14 01:33, Zoran Markovic wrote:
> From: Shaibal Dutta <shaibal.dutta@broadcom.com>

[...]

> -		schedule_delayed_work(&linkwatch_work, delay);
> +		queue_delayed_work(system_power_efficient_wq,
> +			&linkwatch_work, delay);

before talking about technical details, here and in other spots of this
patch the alignment is wrong. I think checkpatch should have said
something about it. The first parameter on the new line should be
aligned up to the column after the opening parenthesis.

Regards,

>  }
> =20
> =20
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index c03f3de..2c8f839 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -101,7 +101,8 @@ static void queue_process(struct work_struct *work)=

>  			__netif_tx_unlock(txq);
>  			local_irq_restore(flags);
> =20
> -			schedule_delayed_work(&npinfo->tx_work, HZ/10);
> +			queue_delayed_work(system_power_efficient_wq,
> +				&npinfo->tx_work, HZ/10);
>  			return;
>  		}
>  		__netif_tx_unlock(txq);
> @@ -423,7 +424,8 @@ void netpoll_send_skb_on_dev(struct netpoll *np, st=
ruct sk_buff *skb,
> =20
>  	if (status !=3D NETDEV_TX_OK) {
>  		skb_queue_tail(&npinfo->txq, skb);
> -		schedule_delayed_work(&npinfo->tx_work,0);
> +		queue_delayed_work(system_power_efficient_wq,
> +			&npinfo->tx_work, 0);
>  	}
>  }
>  EXPORT_SYMBOL(netpoll_send_skb_on_dev);
>=20


--=20
Antonio Quartulli


--FgmjO4qw8O7x8rjEXkT6tBV3b3GrgqAVj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS6vLqAAoJEEKTMo6mOh1Vc90P/iKvO5sq4ALPq8OWN/NMb/Au
WS+vNv3SWrjfV0he63ASF7a9Ygb2CTwsBfnAz6+fxkZZopUMIBFyt4lOa34bTxjh
ycZZ6DyZbSpLIUTEoD9o5MSVPviVX3OulKDtG+np5FwTrf+Yt3KI6jwmSohXO2M6
fAnh2kxSVrlfe7tanvXhV1a6XMkVAnjxDVdE/zcXr7N5LEQF29g94SfutrUZZS8E
OO+87loydMq9XAD2/uV5UlJ2RmzQP0bEbkW5cDKJ4HXN19HsNTygl8sj8BqupWAK
ousndDG2zqznta0pCiNeh9Szxvpqd/UVsxsb70S3sPGDbJXpoUuxDTSUpAUnbdkj
NhVJnGq31AGSpmGWYDNYeuVEZWmP8WlbWzpvI9zal3neS7HOnMo/gIVirXLDEz3M
NzkVqat9QtaJIhumiiRDykVCLYInjEMhGb3LPsUgkLRK8b1O1nhK50cPuP2X4XXh
fD9rplHBm6XPd5jL9KOQwKq55MsJyLQHwA6mt6rpAAsSh7VcNEQZ/qEhtGzMSVTx
yi0CPwwiKDzfvWYD44LkLVEsfAT3d3pCd7ORmNj5Ed2cZMURv9l2g2af6jKPfBs6
Wq3sTbFAg82OL9sBTQOirU65Aowgz6YYelkMQC/tY+tlOnZWCm8SQD2BQXRGJFwt
3Fr05KFkwUuSmX/hN8IY
=Nmm0
-----END PGP SIGNATURE-----

--FgmjO4qw8O7x8rjEXkT6tBV3b3GrgqAVj--

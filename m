From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] caif: Fix compile warning in caif_serial.c
Date: Fri, 27 May 2011 08:37:23 -0700
Message-ID: <4DDFC533.2080305@oracle.com>
References: <20110526143006.2d1ef9f7.randy.dunlap@oracle.com> <1306483755-3588-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, balbi@ti.com, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1306483755-3588-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27/11 01:09, Sjur Br=E6ndeland wrote:
> Fix the compile warning introduced by the patch:
> "tty: make receive_buf() return the amout of bytes received"
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> ---
> Note: Fixes compile issue in linux-next (no issue in net-2.6).

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks much, Sjur.

>  drivers/net/caif/caif_serial.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_s=
erial.c
> index 73c7e03..751ebbd 100644
> --- a/drivers/net/caif/caif_serial.c
> +++ b/drivers/net/caif/caif_serial.c
> @@ -191,7 +191,7 @@ static unsigned int ldisc_receive(struct tty_stru=
ct *tty,
>  		dev_info(&ser->dev->dev,
>  			"Bytes received before initial transmission -"
>  			"bytes discarded.\n");
> -		return;
> +		return count;
>  	}
> =20
>  	BUG_ON(ser->dev =3D=3D NULL);
> @@ -199,7 +199,7 @@ static unsigned int ldisc_receive(struct tty_stru=
ct *tty,
>  	/* Get a suitable caif packet and copy in data. */
>  	skb =3D netdev_alloc_skb(ser->dev, count+1);
>  	if (skb =3D=3D NULL)
> -		return;
> +		return 0;
>  	p =3D skb_put(skb, count);
>  	memcpy(p, data, count);
> =20


--=20
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***

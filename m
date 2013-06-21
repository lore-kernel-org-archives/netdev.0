From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Fwd: Re: [PATCH] can: usb_8dev: unregister netdev before free()ing
Date: Fri, 21 Jun 2013 21:04:23 +0200
Message-ID: <51C4A3B7.9040903@hartkopp.net>
References: <51C1DC58.2040705@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:43178 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423554Ab3FUTE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 15:04:26 -0400
In-Reply-To: <51C1DC58.2040705@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Greg,

can you please integrate this patch into stable 3.9 too?
The usb_8dev driver was introduced in Linux 3.9 and has now been fixed =
in
DaveMs net-tree for 3.10 some days ago.

Upstream commit 4afe2156eb639e563d6ef0c2706b66ea400348b2

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3D=
4afe2156eb639e563d6ef0c2706b66ea400348b2

I wanted to put stable@kernel.org in CC but that bounced.

Tnx,
Oliver


-------- Original Message --------
Subject: Re: [PATCH] can: usb_8dev: unregister netdev before free()ing
Date: Wed, 19 Jun 2013 18:29:12 +0200
=46rom: Oliver Hartkopp <socketcan@hartkopp.net>
To: Marc Kleine-Budde <mkl@pengutronix.de>
CC: netdev@vger.kernel.org, linux-can@vger.kernel.org, davem@davemloft.=
net, stable@kernel.org, Bernd Krumb=F6ck  <krumboeck@universalnet.at>

Hello Marc,

the usb_8dev driver was introduced in Linux 3.9 and therefore this reas=
onable
patch should be queued up for linux-3.9.y stable too.

Regards,
Oliver


On 19.06.2013 09:02, Marc Kleine-Budde wrote:
> The usb_8dev hardware has problems on some xhci USB hosts. The driver=
 fails to
> read the firmware revision in the probe function. This leads to the f=
ollowing
> Oops:
>=20
>     [ 3356.635912] kernel BUG at net/core/dev.c:5701!
>=20
> The driver tries to free the netdev, which has already been registere=
d, without
> unregistering it.
>=20
> This patch fixes the problem by unregistering the netdev in the error=
 path.
>=20
> Reported-by: Michael Olbrich <m.olbrich@pengutronix.de>
> Reviewed-by: Bernd Krumboeck <krumboeck@universalnet.at>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>  drivers/net/can/usb/usb_8dev.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb=
_8dev.c
> index 6e15ef0..cbd388e 100644
> --- a/drivers/net/can/usb/usb_8dev.c
> +++ b/drivers/net/can/usb/usb_8dev.c
> @@ -977,7 +977,7 @@ static int usb_8dev_probe(struct usb_interface *i=
ntf,
>  	err =3D usb_8dev_cmd_version(priv, &version);
>  	if (err) {
>  		netdev_err(netdev, "can't get firmware version\n");
> -		goto cleanup_cmd_msg_buffer;
> +		goto cleanup_unregister_candev;
>  	} else {
>  		netdev_info(netdev,
>  			 "firmware: %d.%d, hardware: %d.%d\n",
> @@ -989,6 +989,9 @@ static int usb_8dev_probe(struct usb_interface *i=
ntf,
> =20
>  	return 0;
> =20
> +cleanup_unregister_candev:
> +	unregister_netdev(priv->netdev);
> +
>  cleanup_cmd_msg_buffer:
>  	kfree(priv->cmd_msg_buffer);
> =20
>=20


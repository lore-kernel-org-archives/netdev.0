From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Tue, 4 Apr 2017 17:34:02 +0200
Message-ID: <145b8725-c3dd-e899-8a3e-133e68a3b1e6@pengutronix.de>
References: <1489785040-26477-1-git-send-email-akshay.bhat@timesys.com>
 <1489785040-26477-2-git-send-email-akshay.bhat@timesys.com>
 <32114de2-8ab7-daec-9b36-209cab0ea550@timesys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Ou3NJ88cjXeCF4a4HFmoLIfH65plqiWi9"
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <32114de2-8ab7-daec-9b36-209cab0ea550-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ou3NJ88cjXeCF4a4HFmoLIfH65plqiWi9
Content-Type: multipart/mixed; boundary="jNFWwvbh4tEe0jMhE2oCrWDvaB6i99xI2";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Message-ID: <145b8725-c3dd-e899-8a3e-133e68a3b1e6-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
References: <1489785040-26477-1-git-send-email-akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
 <1489785040-26477-2-git-send-email-akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
 <32114de2-8ab7-daec-9b36-209cab0ea550-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <32114de2-8ab7-daec-9b36-209cab0ea550-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>

--jNFWwvbh4tEe0jMhE2oCrWDvaB6i99xI2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/24/2017 06:20 PM, Akshay Bhat wrote:
> Hi Marc,
>=20
> On 03/17/2017 05:10 PM, Akshay Bhat wrote:
>> This patch adds support for the Holt HI-311x CAN controller. The HI311=
x
>> CAN controller is capable of transmitting and receiving standard data
>> frames, extended data frames and remote frames. The HI311x interfaces
>> with the host over SPI.
>>
>> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>>
>> Signed-off-by: Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>
>=20
> If there are no further review comments can this series be applied to
> can-next or does it need to wait for the next kernel release cycle (4.1=
3)?

The driver doesn't check if the workqueue allocation is successfull,
I've squashed this patch:

> diff --git a/drivers/net/can/spi/hi311x.c b/drivers/net/can/spi/hi311x.=
c
> index ff4bb40d855e..170e8e3971b2 100644
> --- a/drivers/net/can/spi/hi311x.c
> +++ b/drivers/net/can/spi/hi311x.c
> @@ -780,20 +780,24 @@ static int hi3110_open(struct net_device *net)
> =20
>         priv->wq =3D alloc_workqueue("hi3110_wq", WQ_FREEZABLE | WQ_MEM=
_RECLAIM,
>                                    0);
> +       if (!priv->wq) {
> +               ret =3D -ENOMEM;
> +               goto out_free_irq;
> +       }
>         INIT_WORK(&priv->tx_work, hi3110_tx_work_handler);
>         INIT_WORK(&priv->restart_work, hi3110_restart_work_handler);
> =20
>         ret =3D hi3110_hw_reset(spi);
>         if (ret)
> -               goto out_free_irq;
> +               goto out_free_wq;
> =20
>         ret =3D hi3110_setup(net);
>         if (ret)
> -               goto out_free_irq;
> +               goto out_free_wq;
> =20
>         ret =3D hi3110_set_normal_mode(spi);
>         if (ret)
> -               goto out_free_irq;
> +               goto out_free_wq;
> =20
>         can_led_event(net, CAN_LED_EVENT_OPEN);
>         netif_wake_queue(net);
> @@ -801,11 +805,12 @@ static int hi3110_open(struct net_device *net)
> =20
>         return 0;
> =20
> -out_free_irq:
> + out_free_wq:
> +       destroy_workqueue(priv->wq);
> + out_free_irq:
>         free_irq(spi->irq, priv);
>         hi3110_hw_sleep(spi);
> -
> -out_close:
> + out_close:
>         hi3110_power_enable(priv->transceiver, 0);
>         close_candev(net);
>         mutex_unlock(&priv->hi3110_lock);

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--jNFWwvbh4tEe0jMhE2oCrWDvaB6i99xI2--

--Ou3NJ88cjXeCF4a4HFmoLIfH65plqiWi9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAljjvOoACgkQHv7KIOw4
HPY0cwf8D0AHTCaiMeT20EYHvmn1V7ckfhQHLdabULzQeT7QlbzhFZ9c4Ej1q9Bv
QoKK+EWo5TNscBLzdKjxMMR212jomD8W0MdfnhhA+pxtLs0uTJZSQSXB8KQeFavq
OvRYroXKuPl8LlsWFW2zxunEnQXTjabec6G/4l2M83vLK3wT1BiY1JGQEaaSpTui
7DUMNamE6JSXo9iJaMVGYhJ+m+fngbT++0Byl66kbqu+qfU339rw9/g9r5gHvcjC
NyMcbGQq348gQZCdkmhuBASRK2ZDTA6zxwJ8wbWl8bppYJYxbN/rWufUC+08UQqB
EBOUQIw31mGj6YMWI+ClnW4NSG35ag==
=X5XG
-----END PGP SIGNATURE-----

--Ou3NJ88cjXeCF4a4HFmoLIfH65plqiWi9--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

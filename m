From: "Paul Rolland" <rol@as2917.net>
Subject: RE: [2.6.5] Bad scheduling while atomic
Date: Sun, 18 Apr 2004 20:50:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404181851.i3IIp1107295@tag.witbe.net>
References: <20040416131633.1bfbfa4c@dell_ss3.pdx.osdl.net>
Reply-To: <rol@as2917.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "'Paul Rolland'" <rol@witbe.net>, <linux-kernel@vger.kernel.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'David S. Miller'" <davem@redhat.com>
In-Reply-To: <20040416131633.1bfbfa4c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks Stephen for being so fast !

Regards,
Paul

Paul Rolland, rol(at)as2917.net
ex-AS2917 Network administrator and Peering Coordinator

--

Please no HTML, I'm not a browser - Pas d'HTML, je ne suis pas un navigat=
eur

"Some people dream of success... while others wake up and work hard at it=
"=20

 =20

> -----Message d'origine-----
> De : linux-kernel-owner@vger.kernel.org=20
> [mailto:linux-kernel-owner@vger.kernel.org] De la part de=20
> Stephen Hemminger
> Envoy=E9 : vendredi 16 avril 2004 22:17
> =C0 : David S. Miller
> Cc : Paul Rolland; linux-kernel@vger.kernel.org; netdev@oss.sgi.com
> Objet : Re: [2.6.5] Bad scheduling while atomic
>=20
> Bring up/down network devices with lapbether causes scheduling while
> atomic (if preempt enabled).
>=20
> The calls to rcu_read_lock are unnecessary since lapb_device_event=20
> is called from notifier with the rtnetlink semaphore held, it is
> already protected from the labp_devices list changing.
>=20
> Patch against 2.6.6-rc1
>=20
> diff -Nru a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
> --- a/drivers/net/wan/lapbether.c	Fri Apr 16 11:00:35 2004
> +++ b/drivers/net/wan/lapbether.c	Fri Apr 16 11:00:35 2004
> @@ -392,6 +392,8 @@
> =20
>  /*
>   *	Handle device status changes.
> + *
> + * Called from notifier with RTNL held.
>   */
>  static int lapbeth_device_event(struct notifier_block *this,
>  				unsigned long event, void *ptr)
> @@ -402,7 +404,6 @@
>  	if (!dev_is_ethdev(dev))
>  		return NOTIFY_DONE;
> =20
> -	rcu_read_lock();
>  	switch (event) {
>  	case NETDEV_UP:
>  		/* New ethernet device -> new LAPB interface	 */
> @@ -422,7 +423,6 @@
>  			lapbeth_free_device(lapbeth);
>  		break;
>  	}
> -	rcu_read_unlock();
> =20
>  	return NOTIFY_DONE;
>  }
> -
> To unsubscribe from this list: send the line "unsubscribe=20
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20

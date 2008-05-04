From: devzero@web.de
Subject: Re: 24rc8: unregister_netdevice: waiting for ... to become free
Date: Sun, 04 May 2008 11:33:12 +0200
Message-ID: <264300966@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, g4klx@g4klx.demon.co.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755520AbYEDJd3@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Roland, does this fix your bug?

Yes!=20
With this patch i can unload the nic driver again.
Thank you !



> -----Urspr=FCngliche Nachricht-----
> Von: "David Miller" <davem@davemloft.net>
> Gesendet: 04.05.08 06:11:32
> An: devzero@web.de
> CC: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, netdev@v=
ger.kernel.org, g4klx@g4klx.demon.co.uk
> Betreff: Re: 24rc8: unregister_netdevice: waiting for ... to become f=
ree


> From: David Miller <davem@davemloft.net>
> Date: Fri, 02 May 2008 05:45:36 -0700 (PDT)
>=20
> > From: "Roland" <devzero@web.de>
> > Date: Fri, 2 May 2008 14:38:36 +0200
> >=20
> > > it seems it`s lapbether driver
> > >=20
> > > reproduce:
> > >=20
> > > on system with pcnet32 (vmware) do
> > >=20
> > > modprobe pcnet32
> > > modprobe lapbether
> > > modprobe -r lapbether
> > > modprobe -r pcnet32 -> hang -> unregister_netdevice: waiting for =
eth0 to=20
> > > become free
> >=20
> > lapbeth_cleanup_driver() unregisters the netdevice, but does not
> > release the reference to lapbeth->ethdev in those device instances.
> >=20
> > Once this happens, and the lapbeth_dev_notifier is unregistered,
> > these references will leak forever.
>=20
> Roland, does this fix your bug?
>=20
> lapbeth: Release ->ethdev when unregistering device.
>=20
> Otherwise it leaks forever.
>=20
> Based upon a report by Roland <devzero@web.de>
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.=
c
> index b5860b9..24fd613 100644
> --- a/drivers/net/wan/lapbether.c
> +++ b/drivers/net/wan/lapbether.c
> @@ -459,6 +459,7 @@ static void __exit lapbeth_cleanup_driver(void)
>  	list_for_each_safe(entry, tmp, &lapbeth_devices) {
>  		lapbeth =3D list_entry(entry, struct lapbethdev, node);
> =20
> +		dev_put(lapbeth->ethdev);
>  		unregister_netdevice(lapbeth->axdev);
>  	}
>  	rtnl_unlock();

Acked-by: Roland Kletzing <devzero@web.de>


_______________________________________________________________________
Jetzt neu! Sch=FCtzen Sie Ihren PC mit McAfee und WEB.DE. 30 Tage
kostenlos testen. http://www.pc-sicherheit.web.de/startseite/?mc=3D0222=
20

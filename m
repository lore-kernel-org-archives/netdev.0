From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5 3/5] netdev: ethernet dev_alloc_skb to netdev_alloc_skb
Date: Tue, 7 Feb 2012 21:04:07 +0100
Message-ID: <CAMuHMdXFz5zEWUkrJjNvOqkgt-n2uKc3wzD9H5NKKz1LT4BpOw@mail.gmail.com>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
	<ef62da964e8660dfdf2a25cd643631bb15914ecf.1328445742.git.netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Linux-Next <linux-next@vger.kernel.org>
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <ef62da964e8660dfdf2a25cd643631bb15914ecf.1328445742.git.netdev@pradeepdalvi.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 5, 2012 at 13:50, Pradeep A. Dalvi <netdev@pradeepdalvi.com=
> wrote:
> diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ether=
net/natsemi/sonic.c
> index 26e25d7..0452e296 100644
> --- a/drivers/net/ethernet/natsemi/sonic.c
> +++ b/drivers/net/ethernet/natsemi/sonic.c
> @@ -51,7 +51,7 @@ static int sonic_open(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk("sonic_=
open: initializing sonic driver.\n");
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < SONIC_NUM_RRS; i++) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *sk=
b =3D dev_alloc_skb(SONIC_RBSIZE + 2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sk_buff *sk=
b =3D netdev_alloc_skb(dev, SONIC_RBSIZE + 2);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb =3D=3D=
 NULL) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0while(i > 0) { /* free any that were allocated successful=
ly */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i--;
> @@ -422,7 +422,7 @@ static void sonic_rx(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0status =3D son=
ic_rda_get(dev, entry, SONIC_RD_STATUS);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (status & S=
ONIC_RCR_PRX) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0/* Malloc up new buffer. */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 new_skb =3D dev_alloc_skb(SONIC_RBSIZE + 2);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 new_skb =3D netdev_alloc_skb(SONIC_RBSIZE + 2);

drivers/net/ethernet/natsemi/sonic.c:425: error: too few arguments to
function 'netdev_alloc_skb'

cfr. m68k/defconfig http://kisskb.ellerman.id.au/kisskb/buildresult/558=
3743/

Your search-and-replace script (hmm, you haven't used a script, have
you?) forgot
to add the first "dev" parameter.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (new_skb =3D=3D NULL) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_ERR "%s: Memory s=
queeze, dropping packet.\n", dev->name);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lp->stats.rx_dropped++;

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds

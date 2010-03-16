From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 17:00:39 +0200
Message-ID: <20100316145914.GB3332@swordfish.minsk.epam.com>
References: <20100307192305.GA598@elte.hu>
 <20100308125122.GA11242@redhat.com>
 <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8X7/QrJGcKSMr1RN"
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1268699602.2824.14.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--8X7/QrJGcKSMr1RN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Nope!
Here it is:


[17250.998293] ------------[ cut here ]------------
[17250.998305] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xc1/0x=
125()
[17250.998308] Hardware name: F3JC               =20
[17250.998312] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[17250.998315] Modules linked in: pktgen ppp_async crc_ccitt ipv6 ppp_gener=
ic slhc snd_hwdep snd_hda_codec_si3054 snd_hda_codec_realtek sdhci_pci sdhc=
i asus_laptop sparse_keymap
mmc_core led_class snd_hda_intel snd_hda_codec snd_pcm snd_timer snd_page_a=
lloc rng_core sg evdev i2c_i801 snd soundcore psmouse r8169 serio_raw mii u=
hci_hcd ehci_hcd sr_mod
usbcore cdrom sd_mod ata_piix
[17250.998371] Pid: 3985, comm: kpktgend_0 Tainted: G        W  2.6.34-rc1-=
dbg-git6-r8169 #46
[17250.998375] Call Trace:
[17250.998383]  [<c102e353>] warn_slowpath_common+0x65/0x7c
[17250.998388]  [<c126b654>] ? dev_watchdog+0xc1/0x125
[17250.998393]  [<c102e39e>] warn_slowpath_fmt+0x24/0x27
[17250.998398]  [<c126b654>] dev_watchdog+0xc1/0x125
[17250.998405]  [<c1036bbb>] ? run_timer_softirq+0x120/0x1eb
[17250.998411]  [<c1036c11>] run_timer_softirq+0x176/0x1eb
[17250.998416]  [<c1036bbb>] ? run_timer_softirq+0x120/0x1eb
[17250.998421]  [<c126b593>] ? dev_watchdog+0x0/0x125
[17250.998426]  [<c1032df9>] __do_softirq+0x8d/0x117
[17250.998431]  [<c1032eae>] do_softirq+0x2b/0x43
[17250.998436]  [<c1032fd3>] irq_exit+0x38/0x75
[17250.998442]  [<c1014e75>] smp_apic_timer_interrupt+0x66/0x74
[17250.998448]  [<c12c812a>] apic_timer_interrupt+0x36/0x3c
[17250.998457]  [<c1185d18>] ? do_raw_spin_trylock+0x28/0x37
[17250.998464]  [<c12c7101>] _raw_spin_lock+0x2f/0x58
[17250.998472]  [<f80855ca>] ? spin_lock+0x8/0xa [pktgen]
[17250.998478]  [<f80855ca>] spin_lock+0x8/0xa [pktgen]
[17250.998484]  [<f80873b6>] pktgen_thread_worker+0x9b/0x631 [pktgen]
[17250.998491]  [<c103f9f1>] ? autoremove_wake_function+0x0/0x2f
[17250.998497]  [<c103f9f1>] ? autoremove_wake_function+0x0/0x2f
[17250.998503]  [<f808731b>] ? pktgen_thread_worker+0x0/0x631 [pktgen]
[17250.998508]  [<c103f6ce>] kthread+0x6a/0x6f
[17250.998514]  [<c103f664>] ? kthread+0x0/0x6f
[17250.998520]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
[17250.998523] ---[ end trace a22d306b065d4a68 ]---
[17251.011663] r8169 0000:02:00.0: eth0: link up

[17419.011748] NOHZ: local_softirq_pending 08



	Sergey


On (03/16/10 01:33), Eric Dumazet wrote:
> > Yes, this is wrong. In this context (process context, not softirq), we
> > should use netif_rx() or just drop frames if we are in reset phase.
> >=20
>=20
> Sergey,
>=20
> Here is a compiled but untested patch (I dont have the hardware), could
> you please test it ?
>=20
> Thanks
>=20
> [PATCH] r8169: Fix rtl8169_rx_interrupt()
>=20
> In case a reset is performed, rtl8169_rx_interrupt() is called from
> process context instead of softirq context. Special care must be taken
> to call appropriate network core services (netif_rx() instead of
> netif_receive_skb()). VLAN handling also corrected.
>=20
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Diagnosed-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 9d3ebf3..d873639 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1038,14 +1038,14 @@ static void rtl8169_vlan_rx_register(struct net_d=
evice *dev,
>  }
> =20
>  static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc=
 *desc,
> -			       struct sk_buff *skb)
> +			       struct sk_buff *skb, int polling)
>  {
>  	u32 opts2 =3D le32_to_cpu(desc->opts2);
>  	struct vlan_group *vlgrp =3D tp->vlgrp;
>  	int ret;
> =20
>  	if (vlgrp && (opts2 & RxVlanTag)) {
> -		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
> +		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
>  		ret =3D 0;
>  	} else
>  		ret =3D -1;
> @@ -1062,7 +1062,7 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl816=
9_private *tp,
>  }
> =20
>  static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc=
 *desc,
> -			       struct sk_buff *skb)
> +			       struct sk_buff *skb, int polling)
>  {
>  	return -1;
>  }
> @@ -4429,12 +4429,20 @@ out:
>  	return done;
>  }
> =20
> +/*
> + * Warning : rtl8169_rx_interrupt() might be called :
> + * 1) from NAPI (softirq) context
> + *	(polling =3D 1 : we should call netif_receive_skb())
> + * 2) from process context (rtl8169_reset_task())
> + *	(polling =3D 0 : we must call netif_rx() instead)
> + */	=09
>  static int rtl8169_rx_interrupt(struct net_device *dev,
>  				struct rtl8169_private *tp,
>  				void __iomem *ioaddr, u32 budget)
>  {
>  	unsigned int cur_rx, rx_left;
>  	unsigned int delta, count;
> +	int polling =3D (budget !=3D ~(u32)0) ? 1 : 0;
> =20
>  	cur_rx =3D tp->cur_rx;
>  	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
> @@ -4496,8 +4504,12 @@ static int rtl8169_rx_interrupt(struct net_device =
*dev,
>  			skb_put(skb, pkt_size);
>  			skb->protocol =3D eth_type_trans(skb, dev);
> =20
> -			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
> -				netif_receive_skb(skb);
> +			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
> +				if (likely(polling))
> +					netif_receive_skb(skb);
> +				else
> +					netif_rx(skb);
> +			}
> =20
>  			dev->stats.rx_bytes +=3D pkt_size;
>  			dev->stats.rx_packets++;
>=20
>=20

--8X7/QrJGcKSMr1RN
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkufnRcACgkQfKHnntdSXjQGNAQA3UoUtzDpz3n9BVH435ZiAtwM
eo2HlI+BfYyypiG0qwGAL6hqahT1vGrgBTXQVsIU+rDLxEli26JOGpQfqtMhPV2W
yiApBr2w3+47pcWOdDrGZqftCpmVOtvpCGQBUGZ+Z2ax5GA252sJ2Ybcd7ziu3Bg
Ge0lcfQzlO/rImicX18=
=reK7
-----END PGP SIGNATURE-----

--8X7/QrJGcKSMr1RN--

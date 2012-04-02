From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Mon, 2 Apr 2012 12:21:38 +0100
Message-ID: <20120402105722.GC3172@opensource.wolfsonmicro.com>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
 <1333090806-27988-2-git-send-email-msink@permonline.ru>
 <20120331212303.GB19965@sirena.org.uk>
 <4F797402.1050109@permonline.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d9ADC0YsG2v16Js0"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F797402.1050109@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--d9ADC0YsG2v16Js0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Apr 02, 2012 at 03:40:18PM +0600, Mike Sinkovsky wrote:
> 01.04.2012 3:23, Mark Brown wrote:
> >On Fri, Mar 30, 2012 at 01:00:06PM +0600, Mike Sinkovsky wrote:

> >>+config WIZNET_W5100
> >>+	tristate "WIZnet W5100 Ethernet support"
> >>+	depends on ARM || BLACKFIN

> >What are the architecture dependencies here?

> Original driver from chip manufacturer was written for ARM, and now
> we use it on Blackfin.
> Completely untested on other arch's, but should work. Maybe.

Remove the dependency then.  If there's an issue people can fix it.

> >>+static irqreturn_t w5100_interrupt(int irq, void *ndev_instance)
> >>+{
> >>+	struct net_device *ndev = ndev_instance;
> >>+	struct w5100_priv *priv = netdev_priv(ndev);
> >>+
> >>+	int ir = w5100_read(priv, W5100_S0_IR);
> >>+	w5100_write(priv, W5100_S0_IR, ir);
> >>+
> >>+	if (ir&  S0_IR_RECV) {
> >>+		if (napi_schedule_prep(&priv->napi)) {
> >>+			w5100_write(priv, W5100_IMR, 0);
> >>+			mmiowb();
> >>+			__napi_schedule(&priv->napi);
> >>+		}
> >>+	}
> >>+
> >>+	if (ir&  S0_IR_SENDOK) {
> >>+		if (unlikely(netif_queue_stopped(ndev)))
> >>+			netif_wake_queue(ndev);
> >>+	}
> >>+
> >>+	return IRQ_HANDLED;

> >This unconditionally acknowledges the interrupt even if one wasn't
> >reported by the device.

> Hm? Don't get you.
> W5100_S0_IR register is R/W1C - writing back clears it.
> Or what do you mean?

If you read back and no interrupts are flagged (all bits in the IRQ
status register clear) you'll still return IRQ_HANDLED.

> >This is rather an abuse of the resource API and will run into trouble on
> >device tree based systems.  You should use platform data for non-DT
> >systems.

> Ok, will move it to struct wiznet_platform_data.
> But here is downside - this gpio is optional, and if board doesn't
> have it - it must be initialized as negative value, not just
> omitted.

Sure, this is all totally standard to the Linux GPIO framework.
Realistically treating 0 as an invalid GPIO should be fine.

> >>+		if (request_irq(priv->link_irq, w5100_detect_link,
> >>+				IRQF_TRIGGER_RISING | IRQF_TRIGGER_FALLING,
> >>+				link_name, priv->ndev)<  0)

> >Suggest using request_any_context_irq() to increase the range of
> >supported interrupt controllers.

> Could it be anything but hard irq?

It could be a threaded IRQ (if the interrupt controller can't be
accessed from hard IRQ context).

> >>+	platform_set_drvdata(pdev, NULL);
> >>+	dev_info(&pdev->dev, "probe failed (%d)\n", err);

> >This will be done for you by the driver core.

> You mean platform_set_drvdata() and dev_info()? Maybe.
> I'm sure platform_driver will not do free_netdev() for me.

The error logging.

--d9ADC0YsG2v16Js0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPeYuyAAoJEBus8iNuMP3dRrUP/2TisHVqtx9/HWB8mjueTipt
V6/sb2HFrFyDd5PSe6TDH6qENrsrmc4HCCLshD8C4cYYYw9/HjnD0AH3BNhXiAGc
C4dK3koD69nXslvUm2zKZStox563t1kTcPvy5g8MmJQKRNFotk7K3ElBQXQonHeq
Bo4PygkV5FKyFpWBia7z1Z0fgeXQOIeCdghilwcUnb5syuDuHQHbo9yZA3BM5eUf
MtkDcgiADkuQDP53cU2S0ri3V7zm9Dn9JqXw1EzsCfM+JP7kcSoTajmzyP7qCdVE
GPnPmuoL5RvThiGy6b1CqkIRo4Jh+d6rWfIke9A2Y62pvwzIF0r3uO6TwPMNbAXh
DwxLuZB4HYApbHBM8BUOEsOgJB4y5eG2FDNJLp6sPP8nPj/Dzpxd84v48AjmGFCM
8rdRVX+YXwMbJa25zo7QKyh911DCducZvZJDiWpwB0CNx/4IqbfUwp2NCl+3CKR3
2HbNq/8P3NxJO6dAInFMwilj/jd9Z339Ts+KizsEXpO7hHQxJ3uBgyMnjy59cSRd
DmTHIT8l3YiHzTCdEgMyauCIn1/RorG4SF+rImHX+ZxHoLIVCjari2ZS3+BaTAdh
7ZCnqpsFf2o0RvQh7T0KRk9+/8txwg7dOOCyGSbseVyRL9PLnH3KfxKuiXBL4zJZ
FsA4tdvnksGhKAhf+IzL
=ThM+
-----END PGP SIGNATURE-----

--d9ADC0YsG2v16Js0--

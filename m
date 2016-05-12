From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/5] drivers: replace dev->trans_start accesses
 with dev_trans_start
Date: Thu, 12 May 2016 15:39:55 -0400
Message-ID: <8622dc0c-fd1a-a553-0c55-9ca566149a5d@redhat.com>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285862-30946-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="978cihIIG1clfpM2h1eOhkOiMxPj7sISJ"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462285862-30946-3-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--978cihIIG1clfpM2h1eOhkOiMxPj7sISJ
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/03/2016 10:30 AM, Florian Westphal wrote:
> a trans_start struct member exists twice:
> - in struct net_device (legacy)
> - in struct netdev_queue
>=20
> Instead of open-coding dev->trans_start usage to obtain the current
> trans_start value, use dev_trans_start() instead.
>=20
> This is not exactly the same, as dev_trans_start also considers
> the trans_start values of the netdev queues owned by the device
> and provides the most recent one.
>=20
> For legacy devices this doesn't matter as dev_trans_start can cope
> with netdev trans_start values of 0 (they are ignored).
>=20
> This is a prerequisite to eventual removal of dev->trans_start.
>=20
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
> ---
>  Checkpatch complains about Lines > 80 but I find line break more ugly.=

>=20
>  drivers/infiniband/ulp/ipoib/ipoib_main.c              | 2 +-

For ipoib part,

Acked-by: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

>  drivers/net/ethernet/intel/e1000e/netdev.c             | 2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c              | 2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c          | 2 +-
>  drivers/net/ethernet/microchip/encx24j600.c            | 2 +-
>  drivers/net/ethernet/qualcomm/qca_spi.c                | 2 +-
>  drivers/net/fjes/fjes_main.c                           | 2 +-
>  drivers/net/hamradio/mkiss.c                           | 2 +-
>  drivers/staging/rtl8192e/rtllib_softmac.c              | 2 +-
>  drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c | 2 +-
>  10 files changed, 10 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infini=
band/ulp/ipoib/ipoib_main.c
> index 80807d6..b940ef1 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> @@ -1036,7 +1036,7 @@ static void ipoib_timeout(struct net_device *dev)=

>  	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
> =20
>  	ipoib_warn(priv, "transmit timeout: latency %d msecs\n",
> -		   jiffies_to_msecs(jiffies - dev->trans_start));
> +		   jiffies_to_msecs(jiffies - dev_trans_start(dev)));
>  	ipoib_warn(priv, "queue stopped %d, tx_head %u, tx_tail %u\n",
>  		   netif_queue_stopped(dev),
>  		   priv->tx_head, priv->tx_tail);
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/e=
thernet/intel/e1000e/netdev.c
> index a7f16c3..269087c 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -242,7 +242,7 @@ static void e1000e_dump(struct e1000_adapter *adapt=
er)
>  		dev_info(&adapter->pdev->dev, "Net device Info\n");
>  		pr_info("Device Name     state            trans_start      last_rx\n=
");
>  		pr_info("%-15s %016lX %016lX %016lX\n", netdev->name,
> -			netdev->state, netdev->trans_start, netdev->last_rx);
> +			netdev->state, dev_trans_start(netdev), netdev->last_rx);
>  	}
> =20
>  	/* Print Registers */
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/et=
hernet/intel/igb/igb_main.c
> index 8e96c35..7460bdb 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -383,7 +383,7 @@ static void igb_dump(struct igb_adapter *adapter)
>  		dev_info(&adapter->pdev->dev, "Net device Info\n");
>  		pr_info("Device Name     state            trans_start      last_rx\n=
");
>  		pr_info("%-15s %016lX %016lX %016lX\n", netdev->name,
> -			netdev->state, netdev->trans_start, netdev->last_rx);
> +			netdev->state, dev_trans_start(netdev), netdev->last_rx);
>  	}
> =20
>  	/* Print Registers */
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
> index 0ef4a15..18dcfc5 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -608,7 +608,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapte=
r)
>  		pr_info("%-15s %016lX %016lX %016lX\n",
>  			netdev->name,
>  			netdev->state,
> -			netdev->trans_start,
> +			dev_trans_start(netdev),
>  			netdev->last_rx);
>  	}
> =20
> diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/=
ethernet/microchip/encx24j600.c
> index 7df3183..707283b 100644
> --- a/drivers/net/ethernet/microchip/encx24j600.c
> +++ b/drivers/net/ethernet/microchip/encx24j600.c
> @@ -890,7 +890,7 @@ static void encx24j600_tx_timeout(struct net_device=
 *dev)
>  	struct encx24j600_priv *priv =3D netdev_priv(dev);
> =20
>  	netif_err(priv, tx_err, dev, "TX timeout at %ld, latency %ld\n",
> -		  jiffies, jiffies - dev->trans_start);
> +		  jiffies, jiffies - dev_trans_start(dev));
> =20
>  	dev->stats.tx_errors++;
>  	netif_wake_queue(dev);
> diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethe=
rnet/qualcomm/qca_spi.c
> index 1ef0393..82f3c88 100644
> --- a/drivers/net/ethernet/qualcomm/qca_spi.c
> +++ b/drivers/net/ethernet/qualcomm/qca_spi.c
> @@ -734,7 +734,7 @@ qcaspi_netdev_tx_timeout(struct net_device *dev)
>  	struct qcaspi *qca =3D netdev_priv(dev);
> =20
>  	netdev_info(qca->net_dev, "Transmit timeout at %ld, latency %ld\n",
> -		    jiffies, jiffies - dev->trans_start);
> +		    jiffies, jiffies - dev_trans_start(dev));
>  	qca->net_dev->stats.tx_errors++;
>  	/* Trigger tx queue flush and QCA7000 reset */
>  	qca->sync =3D QCASPI_SYNC_UNKNOWN;
> diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.=
c
> index bb7e903..7ad3d04 100644
> --- a/drivers/net/fjes/fjes_main.c
> +++ b/drivers/net/fjes/fjes_main.c
> @@ -471,7 +471,7 @@ static void fjes_tx_stall_task(struct work_struct *=
work)
>  	int i;
> =20
>  	if (((long)jiffies -
> -		(long)(netdev->trans_start)) > FJES_TX_TX_STALL_TIMEOUT) {
> +		dev_trans_start(netdev)) > FJES_TX_TX_STALL_TIMEOUT) {
>  		netif_wake_queue(netdev);
>  		return;
>  	}
> diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.=
c
> index 85828f1..c685937 100644
> --- a/drivers/net/hamradio/mkiss.c
> +++ b/drivers/net/hamradio/mkiss.c
> @@ -542,7 +542,7 @@ static netdev_tx_t ax_xmit(struct sk_buff *skb, str=
uct net_device *dev)
>  		 * May be we must check transmitter timeout here ?
>  		 *      14 Oct 1994 Dmitry Gorodchanin.
>  		 */
> -		if (time_before(jiffies, dev->trans_start + 20 * HZ)) {
> +		if (time_before(jiffies, dev_trans_start(dev) + 20 * HZ)) {
>  			/* 20 sec timeout not reached */
>  			return NETDEV_TX_BUSY;
>  		}
> diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/stagin=
g/rtl8192e/rtllib_softmac.c
> index cfab715..62154e3 100644
> --- a/drivers/staging/rtl8192e/rtllib_softmac.c
> +++ b/drivers/staging/rtl8192e/rtllib_softmac.c
> @@ -1991,7 +1991,7 @@ static short rtllib_sta_ps_sleep(struct rtllib_de=
vice *ieee, u64 *time)
>  		return 2;
> =20
>  	if (!time_after(jiffies,
> -			ieee->dev->trans_start + msecs_to_jiffies(timeout)))
> +			dev_trans_start(ieee->dev) + msecs_to_jiffies(timeout)))
>  		return 0;
>  	if (!time_after(jiffies,
>  			ieee->last_rx_ps_time + msecs_to_jiffies(timeout)))
> diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/d=
rivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
> index ae1274c..de71450 100644
> --- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
> +++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
> @@ -1737,7 +1737,7 @@ static short ieee80211_sta_ps_sleep(struct ieee80=
211_device *ieee, u32 *time_h,
>  		return 2;
> =20
>  	if(!time_after(jiffies,
> -		       ieee->dev->trans_start + msecs_to_jiffies(timeout)))
> +		       dev_trans_start(ieee->dev) + msecs_to_jiffies(timeout)))
>  		return 0;
> =20
>  	if(!time_after(jiffies,
>=20


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--978cihIIG1clfpM2h1eOhkOiMxPj7sISJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNNwLAAoJELgmozMOVy/dAcEP/0CkWNUUOAj/oJg0JzJr6uGm
oWfdhul/GP8X4SL/MuMES+Zj2u0U3hTngWpDj+59dkKYIBnuNijjCFnpYdzbPXrw
F3UCHDoDdVfc+ANCtwoaFT5juSJMimTWSQF4ql9wy3yIOjhc62hiqWmUwBZoDyeH
NDqq1E7ay7x8g8GOEGikFcDxWrwOIA2mBMNY7+8jgVgcF5aPLEXHb5eapzVh+bCB
KLHv1Jej7hx0zIga+pOe4Cyi2b9Wn/iBuGvwxiLp2inkf2UqaeuGn+a8Hm5xCF0U
6nOQ1gT+Q5VUZQnqKrzwmTq3CeWoSm9cl4FRfr/fiKmL3SGZ/J22aYKnHPB5js4+
CAsn+3piZb9EPaPlidPx0qpl7M4AAfrFGIfCNfVS8ypS+Gx1p4GRu2W7vIR62wa3
Xw6DhXwG/C9bkeO6415pxWLYmqyrZ55EMbHmV/EckzQF/UBGE8ZyU/uZrh3pYrat
FYo3QuYg/OOvvgtA/xtNB9CiVU6OouPYq1+B+AGXDRRBtPuSK45UR7RIvrw4ZEqH
WVEpH1jyg9n+70NVHNq0TR5mafal3IS2kM1eJIQwoD5mYNItUzoi4S0xqlhcEGzZ
cPS+3Sx6SoRdhz+PnbA/epOb25k9w8rovaVDAPU2CjlriP6HaNop4r09THPeCI07
lwKZoDJxopRDwZ9qbX8S
=xm9L
-----END PGP SIGNATURE-----

--978cihIIG1clfpM2h1eOhkOiMxPj7sISJ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

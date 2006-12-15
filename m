From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] d80211: add IEEE802.11e/WMM Traffic Stream (TS)
	Management support
Date: Fri, 15 Dec 2006 15:56:35 +0100
Message-ID: <1166194595.3462.19.camel@johannes.berg>
References: <20061214040237.GA10670@mail.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9MAtQojAbQRMprIS6RyM"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55412 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbWLOO4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 09:56:18 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040237.GA10670@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-9MAtQojAbQRMprIS6RyM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Some comments...

In these cases=20
=20
> +		init_timer(&ifsta->admit_timer);
> +		ifsta->admit_timer.data =3D (unsigned long) dev;
> +		ifsta->admit_timer.function =3D ieee80211_admit_refresh;

> +void ieee80211_send_addts(struct net_device *dev,
> +                         struct ieee802_11_elem_tspec *tspec)

> +void wmm_send_addts(struct net_device *dev, struct ieee802_11_elem_tspec=
 *tspec)

> +void ieee80211_send_delts(struct net_device *dev, u8 tsid, u8 direction,
> +                         u32 medium_time)

> +void wmm_send_delts(struct net_device *dev, u8 tsid, u8 direction,
> +                   u32 medium_time)

please don't use the device as the argument but rather the sdata. Using
the device only to unwrap it to the sdata again isn't really nice.

> +	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, 24);
> +	memset(mgmt, 0, 24);
> +	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
> +	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
> +	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);

No need to zero out the structure if you set all fields anyway.

> +	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, 24);
> +	memset(mgmt, 0, 24);
> +	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
> +	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
> +	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
> +	mgmt->frame_control =3D IEEE80211_FC(IEEE80211_FTYPE_MGMT,
> +					   IEEE80211_STYPE_ACTION);

same here.

> +	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, 24);
> +	memset(mgmt, 0, 24);

and here, and in a few more places.=20
=20
> +static u32 calculate_mpdu_exchange_time(struct ieee802_11_elem_tspec *ts=
pec)
> +{
> +	/*
> +	 * MPDUExchangeTime =3D duration(Nominal MSDU Size, Min PHY Rate) +
> +	 *		      SIFS + ACK duration
> +	 */
> +	return 5000;
> +}

Is this correct? Aren't some of those things variable?

> +	printk(KERN_DEBUG "Dialog_token: %d, TID: %u, Direction: %u, PSB: %d, "
> +	       "UP: %d\n", mgmt->u.action.u.wme_action.dialog_token,
> +	       tspec->ts_info.tsid, tspec->ts_info.direction,
> +	       tspec->ts_info.apsd, tspec->ts_info.up);

Can we have those printks optional?

> +static void ieee80211_rx_mgmt_action(struct net_device *dev,

> +	if (len < 24 + 1) {
> +		printk(KERN_DEBUG "%s: too short (%zd) action frame "
> +		       "received from " MAC_FMT " - ignored\n",
> +		       dev->name, len, MAC_ARG(mgmt->sa));
> +		return;
> +	}

Do we really want this if in all possibilities where we use the data it
needs to be 24+4 long?

> +	case WLAN_CATEGORY_DLS:
> +	case WLAN_CATEGORY_BACK:
> +	default:
> +		printk(KERN_ERR "%s: unsupported action category %d\n",
> +		       dev->name, mgmt->u.action.category);
> +		break;

I don't think these are KERN_ERR.=20
=20
johannes

--=-9MAtQojAbQRMprIS6RyM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFgrej/ETPhpq3jKURAobfAJ4u6qiEbUxRrfcLx7TtHm6Q7/AYjwCfZUvn
nOeHZuhFApobA5Xl3K6nSLs=
=CEE6
-----END PGP SIGNATURE-----

--=-9MAtQojAbQRMprIS6RyM--


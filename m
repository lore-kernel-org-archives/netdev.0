From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2012-07-09
Date: Mon, 9 Jul 2012 15:43:30 -0400
Message-ID: <20120709194330.GF1348@tuxdriver.com>
References: <20120709192818.GE1348@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49192 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab2GITs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 15:48:29 -0400
Content-Disposition: inline
In-Reply-To: <20120709192818.GE1348@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Forgot to sign -- hopefully this is sufficient? :-)

On Mon, Jul 09, 2012 at 03:28:18PM -0400, John W. Linville wrote:
> commit c1109736bcdd14b590392e9a96d66e7e823f9e67
>=20
> Dave,
>=20
> Please accept these fixes for the 3.5 stream...
>=20
> Bing Zhao provides an mwifiex fix for a memory leak uncovered by
> Coverity.
>=20
> Eliad Peller provides a mac80211 fix to properly clean-up after an
> association failure.
>=20
> Emmanuel Grumbach gives us an iwlegacy fix to avoid some on-device
> memory corruption that leads to a stuck queue.
>=20
> Sasha Levin offers an NFC fix to prevent a NULL pointer dereference
> in llcp_sock_getname.
>=20
> Stanislaw Gruszka offers an rt2x00usb fix for an RX queue stall that
> results from using the wrong argument order in a macro call.  He also
> gives us an iwlegacy fix that corresponds to an already merged iwlwifi
> fix, the effect of which is to avoid stuck queue detection failure.
>=20
> Finally, Thomas Huehn provides a mac80211 fix to correct some kzalloc
> arguments.  This was originally two patches, but I consolidated them.
>=20
> Please let me know if there are problems!
>=20
> Thanks,
>=20
> John
>=20
> ---
>=20
> The following changes since commit bb3bb3a5b839fa5c0a2c386640e865320a1fb6=
4c:
>=20
>   Merge branch 'master' of git://1984.lsi.us.es/nf (2012-07-09 02:47:59 -=
0700)
>=20
> are available in the git repository at:
>=20
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for=
-davem
>=20
> for you to fetch changes up to c1109736bcdd14b590392e9a96d66e7e823f9e67:
>=20
>   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/=
linville/wireless into for-davem (2012-07-09 15:09:08 -0400)
>=20
> ----------------------------------------------------------------
>=20
> Bing Zhao (1):
>       mwifiex: fix Coverity SCAN CID 709078: Resource leak (RESOURCE_LEAK)
>=20
> Eliad Peller (1):
>       mac80211: destroy assoc_data correctly if assoc fails
>=20
> Emmanuel Grumbach (1):
>       iwlegacy: don't mess up the SCD when removing a key
>=20
> John W. Linville (1):
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless=
 into for-davem
>=20
> Sasha Levin (1):
>       NFC: Prevent NULL deref when getting socket name
>=20
> Stanislaw Gruszka (2):
>       rt2x00usb: fix indexes ordering on RX queue kick
>       iwlegacy: always monitor for stuck queues
>=20
> Thomas Huehn (1):
>       mac80211: correct size the argument to kzalloc in minstrel_ht
>=20
>  drivers/net/wireless/iwlegacy/4965-mac.c |    4 ++--
>  drivers/net/wireless/iwlegacy/common.c   |   14 ++++++--------
>  drivers/net/wireless/mwifiex/cfg80211.c  |    1 +
>  drivers/net/wireless/rt2x00/rt2x00usb.c  |    2 +-
>  net/mac80211/mlme.c                      |    6 ++----
>  net/mac80211/rc80211_minstrel_ht.c       |    2 +-
>  net/nfc/llcp/sock.c                      |    2 +-
>  7 files changed, 14 insertions(+), 17 deletions(-)
>=20
> diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wirel=
ess/iwlegacy/4965-mac.c
> index 509301a..ff5d689 100644
> --- a/drivers/net/wireless/iwlegacy/4965-mac.c
> +++ b/drivers/net/wireless/iwlegacy/4965-mac.c
> @@ -3405,7 +3405,7 @@ il4965_remove_dynamic_key(struct il_priv *il,
>  		return 0;
>  	}
> =20
> -	if (il->stations[sta_id].sta.key.key_offset =3D=3D WEP_INVALID_OFFSET) {
> +	if (il->stations[sta_id].sta.key.key_flags & STA_KEY_FLG_INVALID) {
>  		IL_WARN("Removing wrong key %d 0x%x\n", keyconf->keyidx,
>  			key_flags);
>  		spin_unlock_irqrestore(&il->sta_lock, flags);
> @@ -3420,7 +3420,7 @@ il4965_remove_dynamic_key(struct il_priv *il,
>  	memset(&il->stations[sta_id].sta.key, 0, sizeof(struct il4965_keyinfo));
>  	il->stations[sta_id].sta.key.key_flags =3D
>  	    STA_KEY_FLG_NO_ENC | STA_KEY_FLG_INVALID;
> -	il->stations[sta_id].sta.key.key_offset =3D WEP_INVALID_OFFSET;
> +	il->stations[sta_id].sta.key.key_offset =3D keyconf->hw_key_idx;
>  	il->stations[sta_id].sta.sta.modify_mask =3D STA_MODIFY_KEY_MASK;
>  	il->stations[sta_id].sta.mode =3D STA_CONTROL_MODIFY_MSK;
> =20
> diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireles=
s/iwlegacy/common.c
> index cbf2dc1..5d4807c 100644
> --- a/drivers/net/wireless/iwlegacy/common.c
> +++ b/drivers/net/wireless/iwlegacy/common.c
> @@ -4767,14 +4767,12 @@ il_bg_watchdog(unsigned long data)
>  		return;
> =20
>  	/* monitor and check for other stuck queues */
> -	if (il_is_any_associated(il)) {
> -		for (cnt =3D 0; cnt < il->hw_params.max_txq_num; cnt++) {
> -			/* skip as we already checked the command queue */
> -			if (cnt =3D=3D il->cmd_queue)
> -				continue;
> -			if (il_check_stuck_queue(il, cnt))
> -				return;
> -		}
> +	for (cnt =3D 0; cnt < il->hw_params.max_txq_num; cnt++) {
> +		/* skip as we already checked the command queue */
> +		if (cnt =3D=3D il->cmd_queue)
> +			continue;
> +		if (il_check_stuck_queue(il, cnt))
> +			return;
>  	}
> =20
>  	mod_timer(&il->watchdog,
> diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wirele=
ss/mwifiex/cfg80211.c
> index ce61b6f..5c7fd18 100644
> --- a/drivers/net/wireless/mwifiex/cfg80211.c
> +++ b/drivers/net/wireless/mwifiex/cfg80211.c
> @@ -958,6 +958,7 @@ static int mwifiex_cfg80211_start_ap(struct wiphy *wi=
phy,
>  	case NL80211_HIDDEN_SSID_ZERO_CONTENTS:
>  		/* firmware doesn't support this type of hidden SSID */
>  	default:
> +		kfree(bss_cfg);
>  		return -EINVAL;
>  	}
> =20
> diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wirele=
ss/rt2x00/rt2x00usb.c
> index d357d1e..74ecc33 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00usb.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
> @@ -436,8 +436,8 @@ void rt2x00usb_kick_queue(struct data_queue *queue)
>  	case QID_RX:
>  		if (!rt2x00queue_full(queue))
>  			rt2x00queue_for_each_entry(queue,
> -						   Q_INDEX_DONE,
>  						   Q_INDEX,
> +						   Q_INDEX_DONE,
>  						   NULL,
>  						   rt2x00usb_kick_rx_entry);
>  		break;
> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
> index a4bb856..0db5d34 100644
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@ -2174,15 +2174,13 @@ ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub=
_if_data *sdata,
>  		       sdata->name, mgmt->sa, status_code);
>  		ieee80211_destroy_assoc_data(sdata, false);
>  	} else {
> -		printk(KERN_DEBUG "%s: associated\n", sdata->name);
> -
>  		if (!ieee80211_assoc_success(sdata, *bss, mgmt, len)) {
>  			/* oops -- internal error -- send timeout for now */
> -			ieee80211_destroy_assoc_data(sdata, true);
> -			sta_info_destroy_addr(sdata, mgmt->bssid);
> +			ieee80211_destroy_assoc_data(sdata, false);
>  			cfg80211_put_bss(*bss);
>  			return RX_MGMT_CFG80211_ASSOC_TIMEOUT;
>  		}
> +		printk(KERN_DEBUG "%s: associated\n", sdata->name);
> =20
>  		/*
>  		 * destroy assoc_data afterwards, as otherwise an idle
> diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_mi=
nstrel_ht.c
> index 2d1acc6..f9e51ef 100644
> --- a/net/mac80211/rc80211_minstrel_ht.c
> +++ b/net/mac80211/rc80211_minstrel_ht.c
> @@ -809,7 +809,7 @@ minstrel_ht_alloc_sta(void *priv, struct ieee80211_st=
a *sta, gfp_t gfp)
>  			max_rates =3D sband->n_bitrates;
>  	}
> =20
> -	msp =3D kzalloc(sizeof(struct minstrel_ht_sta), gfp);
> +	msp =3D kzalloc(sizeof(*msp), gfp);
>  	if (!msp)
>  		return NULL;
> =20
> diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
> index 17a707d..e06d458 100644
> --- a/net/nfc/llcp/sock.c
> +++ b/net/nfc/llcp/sock.c
> @@ -292,7 +292,7 @@ static int llcp_sock_getname(struct socket *sock, str=
uct sockaddr *addr,
> =20
>  	pr_debug("%p\n", sk);
> =20
> -	if (llcp_sock =3D=3D NULL)
> +	if (llcp_sock =3D=3D NULL || llcp_sock->dev =3D=3D NULL)
>  		return -EBADFD;
> =20
>  	addr->sa_family =3D AF_NFC;
> --=20
> John W. Linville		Someday the world will need a hero, and you
> linville@tuxdriver.com			might be all we have.  Be ready.

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP+zRhAAoJEJctW/TcYTgGv04P/RIDGtSWjyUHMGZmM1SoQ9ve
oSvQlBh4chv0CFkrfRL8Ru6PKHybVecNH4kL7ef9Q6Qtyr/kaNbjHr+2gNhmTwFS
vIPp5fsPR1CK4bwdh8zYH/4hebcq48yo9FdpgD3qOcrn9wPoQYuXJxwaQltam91P
DUTnkPMDReP0WlRzVPjleWdrGJ7xC3YOIMr5yKncWgfHl1NYVb4nsVXImqpEDqjN
7RrPKI1QqS55O0a+eElnMiWvq4KOB6YEslKNtLYh6WZSLzTdRqFazlyaQRfgEDTt
lVVVxZT14c9RXjwXkmbfA5Se26f2dZ+NN0siCEFE/jidZMACcjZYUOCXYl5qu4xq
+pR4pYsDDxAJ5DP5nzRrKPBj5M5jPCX4FtFrYScfYvX1c29fQolt7pH30ZzLiymx
Yi396QI/hAWQEDoqTF9rPB+gmVZwK9hj7TAyJ9E+TCl8yj0AdxJpaQquHZg5RyFC
3vOulBySxZk9qoS54z4a53tFMTnm8X/BlMfPGjt16DQ3wMK9PNYLOOKbgAyAb72X
WssfuY3U1rMiw9rVuCa3Nn+kr6nYp8lPHbFoPMmoAgGgxKQbBgcaLCiGsI4wg1iz
mwt/jPKvbPJQ30IAuGD5LUwjTXoetcUjS7x1ptVAx3VyKfRCI4s+lFcsp4EB7b48
kJFZXRxY74Ko+FMZ+Tcj
=t6AR
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

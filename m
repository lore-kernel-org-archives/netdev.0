From: Luciano Coelho <luca@coelho.fi>
Subject: Re: [PATCH net-next 04/21] wireless: Convert
 is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Sat, 20 Oct 2012 13:51:14 +0300
Message-ID: <1350730274.14361.1.camel@cumari.coelho.fi>
References: <cover.1350618006.git.joe@perches.com>
	<bb2235c257e347354d94478bd1be35b89bf90186.1350618009.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0519370670=="
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	brcm80211-dev-list@broadcom.com, linux-kernel@vger.kernel.org,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Brett Rudley <brudley@broadcom.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Wingerde <gwingerde@gmail.com>, users@rt2x00.serialmonkey.com,
	Roland Vossen <rvossen@broadcom.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	b43-dev@lists.infradead.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Spriel <arend@broadcom.com>, Daniel Drake <dsd@gentoo.org>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>, Arend@venema.h4ckr.net,
	Johannes Berg <johannes.berg@inte
To: Joe Perches <joe@perches.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <bb2235c257e347354d94478bd1be35b89bf90186.1350618009.git.joe@perches.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Mime-version: 1.0
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org


--===============0519370670==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-uAuTUfX6xn+HtgGe8uKG"


--=-uAuTUfX6xn+HtgGe8uKG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-10-18 at 20:55 -0700, Joe Perches wrote:
> Convert the old ether_addr tests to eth_addr_<foo>.
> Adds api consistency.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

For the TI drivers part:

Acked-by: Luciano Coelho <luca@coelho.fi>

[...]
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless=
/ti/wl1251/main.c
> index 441cbcc..822d1f2 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -338,7 +338,7 @@ static int wl1251_join(struct wl1251 *wl, u8 bss_type=
, u8 channel,
>  	 * Join command applies filters, and if we are not associated,
>  	 * BSSID filter must be disabled for association to work.
>  	 */
> -	if (is_zero_ether_addr(wl->bssid))
> +	if (eth_addr_zero(wl->bssid))
>  		wl->rx_config &=3D ~CFG_BSSID_FILTER_EN;
> =20
>  	ret =3D wl1251_cmd_join(wl, bss_type, channel, beacon_interval,
> @@ -703,7 +703,7 @@ static void wl1251_op_configure_filter(struct ieee802=
11_hw *hw,
>  	}
>  	if (*total & FIF_CONTROL)
>  		wl->rx_filter |=3D CFG_RX_CTL_EN;
> -	if (*total & FIF_OTHER_BSS || is_zero_ether_addr(wl->bssid))
> +	if (*total & FIF_OTHER_BSS || eth_addr_zero(wl->bssid))
>  		wl->rx_config &=3D ~CFG_BSSID_FILTER_EN;
>  	if (*total & FIF_PROBE_REQ)
>  		wl->rx_filter |=3D CFG_RX_PREQ_EN;
> @@ -734,7 +734,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
>  	switch (mac80211_key->cipher) {
>  	case WLAN_CIPHER_SUITE_WEP40:
>  	case WLAN_CIPHER_SUITE_WEP104:
> -		if (is_broadcast_ether_addr(addr))
> +		if (eth_addr_broadcast(addr))
>  			key->key_type =3D KEY_WEP_DEFAULT;
>  		else
>  			key->key_type =3D KEY_WEP_ADDR;
> @@ -742,7 +742,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
>  		mac80211_key->hw_key_idx =3D mac80211_key->keyidx;
>  		break;
>  	case WLAN_CIPHER_SUITE_TKIP:
> -		if (is_broadcast_ether_addr(addr))
> +		if (eth_addr_broadcast(addr))
>  			key->key_type =3D KEY_TKIP_MIC_GROUP;
>  		else
>  			key->key_type =3D KEY_TKIP_MIC_PAIRWISE;
> @@ -750,7 +750,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
>  		mac80211_key->hw_key_idx =3D mac80211_key->keyidx;
>  		break;
>  	case WLAN_CIPHER_SUITE_CCMP:
> -		if (is_broadcast_ether_addr(addr))
> +		if (eth_addr_broadcast(addr))
>  			key->key_type =3D KEY_AES_GROUP;
>  		else
>  			key->key_type =3D KEY_AES_PAIRWISE;
> @@ -793,7 +793,7 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw,=
 enum set_key_cmd cmd,
>  		     key->cipher, key->keyidx, key->keylen, key->flags);
>  	wl1251_dump(DEBUG_CRYPT, "KEY: ", key->key, key->keylen);
> =20
> -	if (is_zero_ether_addr(addr)) {
> +	if (eth_addr_zero(addr)) {
>  		/* We dont support TX only encryption */
>  		ret =3D -EOPNOTSUPP;
>  		goto out;
> diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/=
ti/wlcore/cmd.c
> index eaef3f4..3e40415 100644
> --- a/drivers/net/wireless/ti/wlcore/cmd.c
> +++ b/drivers/net/wireless/ti/wlcore/cmd.c
> @@ -1268,7 +1268,7 @@ int wl1271_cmd_set_sta_key(struct wl1271 *wl, struc=
t wl12xx_vif *wlvif,
> =20
>  	if (key_type =3D=3D KEY_WEP)
>  		cmd->lid_key_type =3D WEP_DEFAULT_LID_TYPE;
> -	else if (is_broadcast_ether_addr(addr))
> +	else if (eth_addr_broadcast(addr))
>  		cmd->lid_key_type =3D BROADCAST_LID_TYPE;
>  	else
>  		cmd->lid_key_type =3D UNICAST_LID_TYPE;
> diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless=
/ti/wlcore/main.c
> index 25530c8..d421844 100644
> --- a/drivers/net/wireless/ti/wlcore/main.c
> +++ b/drivers/net/wireless/ti/wlcore/main.c
> @@ -3020,7 +3020,7 @@ static int wl1271_set_key(struct wl1271 *wl, struct=
 wl12xx_vif *wlvif,
> =20
>  		addr =3D sta ? sta->addr : bcast_addr;
> =20
> -		if (is_zero_ether_addr(addr)) {
> +		if (eth_addr_zero(addr)) {
>  			/* We dont support TX only encryption */
>  			return -EOPNOTSUPP;
>  		}
> @@ -3029,7 +3029,7 @@ static int wl1271_set_key(struct wl1271 *wl, struct=
 wl12xx_vif *wlvif,
>  		   will be cleared automatically on next CMD_JOIN. Ignore the
>  		   request silently, as we dont want the mac80211 to emit
>  		   an error message. */
> -		if (action =3D=3D KEY_REMOVE && !is_broadcast_ether_addr(addr))
> +		if (action =3D=3D KEY_REMOVE && !eth_addr_broadcast(addr))
>  			return 0;
> =20
>  		/* don't remove key if hlid was already deleted */
> @@ -3871,7 +3871,7 @@ static void wl1271_bss_info_changed_sta(struct wl12=
71 *wl,
>  	}
> =20
>  	if (changed & BSS_CHANGED_BSSID)
> -		if (!is_zero_ether_addr(bss_conf->bssid)) {
> +		if (!eth_addr_zero(bss_conf->bssid)) {
>  			ret =3D wl12xx_cmd_build_null_data(wl, wlvif);
>  			if (ret < 0)
>  				goto out;
> diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/t=
i/wlcore/tx.c
> index a90d3cd..03e966e 100644
> --- a/drivers/net/wireless/ti/wlcore/tx.c
> +++ b/drivers/net/wireless/ti/wlcore/tx.c
> @@ -145,7 +145,7 @@ static u8 wl12xx_tx_get_hlid_ap(struct wl1271 *wl, st=
ruct wl12xx_vif *wlvif,
>  			return wl->system_hlid;
> =20
>  		hdr =3D (struct ieee80211_hdr *)skb->data;
> -		if (is_multicast_ether_addr(ieee80211_get_DA(hdr)))
> +		if (eth_addr_multicast(ieee80211_get_DA(hdr)))
>  			return wlvif->ap.bcast_hlid;
>  		else
>  			return wlvif->ap.global_hlid;
[...]

--
Cheers,
Luca.

--=-uAuTUfX6xn+HtgGe8uKG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQgoIiAAoJEKFHnKIaPMX6YfkQALNRKGWfwLmo2ppzvO+xmiXB
EWjfDRvGPv8LNpwKTuPXXq5QmdVvnsy+7Wcq8PBPvMux+x8YsnW8lv9JqVGxLFnv
i5MRUKrGrysEB3pzjNW87VbLotG4XcsUIxkwVIF/UPuoHIGpk9e6UX3nJtR2drSs
T4saW/ZMu92EeOXHZJUvjpANPKtmlSfjR2hpOsp+z8VE2zFs/HwFm9Blc2/ue3In
NlCFG2pF6NVxZIB8zMFh74wn6uUa0tF3KVvyVYPYtgaNnN398AzlsE+qWlM14u2i
zPHwPNAidDGJRV5m2T9fUx8W2vOdDQHD0VYvZ4zjrPaCq4UjD1H6Nk7bZ7oRHKWK
6IiMTB/GR2d8nuqiSr0PMng+S6186mbLnmNy5s/3VbmcHnZHE1OHL9pNKiqCuDWh
En4N2o/IyGJ2ENJduNXhuiCReMNUhC66TGxd4BYCr09KZJ2onI6G87/2/sJOfxAc
CD6kNUhKzfneP2n0iScoDdIyPC8Nd8GbLB42YxfVBRdwRWRhHmlJSQ5VOcgyYRvW
YS6+aFMSAUzJnRjMKYpzf6EAUhtnr5RQKez5rvw1/tkXiU076o4fIOJnUAn1wt2H
/0cIJkCnVDjIerudKhw1imTzMNyguXc4yc5LTqRaYifeX5sHi9YbQhRroDpln/lb
xLPoSfCZ+t95iAg0XADW
=pg3n
-----END PGP SIGNATURE-----

--=-uAuTUfX6xn+HtgGe8uKG--


--===============0519370670==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath9k-devel mailing list
ath9k-devel@lists.ath9k.org
https://lists.ath9k.org/mailman/listinfo/ath9k-devel

--===============0519370670==--

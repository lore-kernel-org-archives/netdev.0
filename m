From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 09/16] wl1251: disable power saving in monitor mode
Date: Wed, 30 Oct 2013 12:46:27 +0100
Message-ID: <20131030114627.GC8763@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-10-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382819655-30430-10-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 2013-10-26 22:34:08, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> Force power saving off while monitor interface is present.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>
> ---
>  drivers/net/wireless/ti/wl1251/main.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wire=
less/ti/wl1251/main.c
> index 727f2ee..62cb374 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -617,7 +617,8 @@ static int wl1251_op_config(struct ieee80211_hw *=
hw, u32 changed)
>  			goto out_sleep;
>  	}
> =20
> -	if (conf->flags & IEEE80211_CONF_PS && !wl->psm_requested) {
> +	if (conf->flags & IEEE80211_CONF_PS && !wl->psm_requested &&
> +	    !wl->monitor_present) {
>  		wl1251_debug(DEBUG_PSM, "psm enabled");
> =20
>  		wl->psm_requested =3D true;
> @@ -633,8 +634,8 @@ static int wl1251_op_config(struct ieee80211_hw *=
hw, u32 changed)
>  		ret =3D wl1251_ps_set_mode(wl, STATION_POWER_SAVE_MODE);
>  		if (ret < 0)
>  			goto out_sleep;
> -	} else if (!(conf->flags & IEEE80211_CONF_PS) &&
> -		   wl->psm_requested) {
> +	} else if ((!(conf->flags & IEEE80211_CONF_PS) || wl->monitor_prese=
nt)
> +		   && wl->psm_requested) {
>  		wl1251_debug(DEBUG_PSM, "psm disabled");
> =20

These boolean expressions make my head spin. Introduce helper function=20

can_do_pm()... return (conf->flags & IEEE80211_CONF_PS) &&
!wl->monitor_present

?

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html

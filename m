From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 13/16] wl1251: enforce changed hw encryption support on
 monitor state change
Date: Wed, 30 Oct 2013 12:55:04 +0100
Message-ID: <20131030115504.GG8763@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1382819655-30430-14-git-send-email-pali.rohar@gmail.com>
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
In-Reply-To: <1382819655-30430-14-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat 2013-10-26 22:34:12, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> The firmware doesn't support per packet encryption selection, so disa=
ble hw
> encryption support completly while a monitor interface is present to =
support

"completely".

> injection of packets (which shouldn't get encrypted by hw).
> To enforce the changed hw encryption support force a disassociation o=
n
> non-monitor interfaces.
> For disassociation a workaround using hw connection monitor is employ=
ed,
> which temporary enables hw connection manager flag.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>

Missing sign-off.

> index 174f403..f054741 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -685,6 +685,16 @@ static int wl1251_op_config(struct ieee80211_hw =
*hw, u32 changed)
>  		wl->power_level =3D conf->power_level;
>  	}
> =20
> +	/*
> +	 * Tell stack that connection is lost because hw encryption isn't
> +	 * supported in monitor mode.
> +	 * XXX This requires temporary enabling the hw connection monitor f=
lag
> +	 */

"of the" and I guess you can remove the XXX? This way it looks like
workaround is not complete.

Thanks,
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html

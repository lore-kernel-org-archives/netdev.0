From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Mon, 18 Jul 2016 20:52:22 +0200
Message-ID: <1468867942.2944.0.camel@sipsolutions.net>
References: <20160713114542.24937-1-yanivma@ti.com>
	 <20160718133824.GA11996@localhost> (sfid-20160718_153832_665157_D129D05B)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160718133824.GA11996@localhost> (sfid-20160718_153832_665157_D129D05B)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-07-18 at 09:38 -0400, Bob Copeland wrote:
> On Wed, Jul 13, 2016 at 02:45:40PM +0300, Yaniv Machani wrote:
> > The HT capab info field inside the HT capab IE of the mesh beacon
> > is incorrect (in the case of 20MHz channel width).
> > To fix this driver will check configuration from cfg and
> > will build it accordingly.
>=20
> > +=C2=A0=C2=A0=C2=A0=C2=A0/* determine capability flags */
> > +	cap =3D sband->ht_cap.cap;
> > +
> > +=C2=A0=C2=A0=C2=A0=C2=A0/* if channel width is 20MHz - configure H=
T capab
> > accordingly*/
> > +	if (sdata->vif.bss_conf.chandef.width =3D=3D
> > NL80211_CHAN_WIDTH_20) {
> > +		cap &=3D ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
> > +		cap &=3D ~IEEE80211_HT_CAP_DSSSCCK40;
> > +	}
>=20
> Is it required that HT capability match the HT operation in this
> case?
>=20

Is there ever a case that HT *capability* should be restricted
artificially like that? I can't remember any cases - we do something
like that to work around broken APs in some cases, but here?

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

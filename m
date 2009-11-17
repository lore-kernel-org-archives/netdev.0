From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Wed, 18 Nov 2009 09:42:38 +1100
Message-ID: <646765f40911171442m467efbc8ped7abc9d529ed095@mail.gmail.com>
References: <1258465585.3682.7.camel@johannes.local> <1258490898.21197.42.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1258490898.21197.42.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2009 at 07:48, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org=
> wrote:
> --- wireless-testing.orig/net/mac80211/iface.c =A02009-11-17 14:20:19=
=2E000000000 +0100
> +++ wireless-testing/net/mac80211/iface.c =A0 =A0 =A0 2009-11-17 17:5=
6:08.000000000 +0100
> @@ -745,6 +745,11 @@ int ieee80211_if_change_type(struct ieee
> =A0 =A0 =A0 =A0if (type =3D=3D sdata->vif.type)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> + =A0 =A0 =A0 /* if it's part of a bridge, reject changing type to st=
ation/ibss */
> + =A0 =A0 =A0 if (sdata->dev->br_port && (type =3D=3D NL80211_IFTYPE_=
ADHOC ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 type =3D=3D NL80211_IFTYPE_STATION))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;

Busy doesn't seem like the right error here ... maybe use -EOPNOTSUPP
like the next test?

Thanks,

--=20

Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
=2EPlan: http://sites.google.com/site/juliancalaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

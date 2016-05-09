From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: Re: [PATCH 2/2] mac80211_hwsim: Allow managing radios from
 non-initial namespaces
Date: Mon, 09 May 2016 18:33:05 +0200
Message-ID: <1462811585.18382.22.camel@strongswan.org>
References: <1462258398-6749-1-git-send-email-martin@strongswan.org>
	 <1462258398-6749-3-git-send-email-martin@strongswan.org>
	 <1462302992.10444.11.camel@sipsolutions.net>
	 <1462350799.2546.31.camel@strongswan.org>
	 <1462779045.30690.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462779045.30690.2.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> > Moving the radio back to the creators namespace would be the most
> > consistent behavior, so I'll check how difficult such a reverse
> > lookup is. We then would delete the radio only if it is in the
> > creators namespace, or if the creators namespace is gone. Does that
> > make sense?

> It does make sense, but it does also feel a bit complicated.=20

Yes, and proper locking gets difficult when using cfg80211_set_netns(),
which can sleep. This would probably need larger changes in the locking
code, but that's IMO not worth the effort.

> Perhaps just special-case the init_net case for consistency with the
> existing behaviour, and reserve netgroup 0 for that so we can easily
> check for it?

I'll do that in a v2, following immediately.

> > I suspect you should be defining a structure that currently=20
> > contains=C2=A0one integer member. Something (maybe a compile time=20
> > assert) needs to check that buffer space you are accessing (where=20
> > ever it is) is large enough.
>=20
> It does look a bit awkward, but there's no value in having a struct -
> you still have an opaque pointer here and cast it to something whose
> size you assume to be present... it really makes no difference.

I agree there is no added safety when using a struct; Nonetheless have
I added one in v2, and is it just for any future member additions.

Best regards
Martin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

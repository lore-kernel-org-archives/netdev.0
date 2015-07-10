From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/3] of_mdio: add new DT property 'autoneg' for fixed-link
Date: Fri, 10 Jul 2015 13:39:44 -0700
Message-ID: <55A02D90.8090903@gmail.com>
References: <559FF511.5080102@list.ru> <559FF63E.8020209@list.ru> <55A010F9.7030808@gmail.com> <55A02656.7020508@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastien Rannou <mxs-i6rsG8ix9II@public.gmane.org>,
	Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55A02656.7020508-cmBhpYW9OiY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/07/15 13:08, Stas Sergeev wrote:
> 10.07.2015 21:37, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On 10/07/15 09:43, Stas Sergeev wrote:
>>> Currently for fixed-link the MAC driver decides whether to use the
>>> link status auto-negotiation or not.
>>> Unfortunately the auto-negotiation may not work when expected by
>>> the MAC driver. Sebastien Rannou explains:
>>> << Yes, I confirm that my HW does not generate an in-band status.
>>> AFAIK, it's
>>> a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PH=
Y
>>> (with
>>> inband status) is connected to the switch through QSGMII, and in th=
is
>>> context
>>> we are on the media side of the PHY. >>
>>> https://lkml.org/lkml/2015/7/10/206
>>>
>>> This patch introduces the new boolean property 'autoneg' that allow=
s
>>> the user to request the auto-negotiation explicitly.
>> The implementation looks better, but the name might still be slightl=
y
>> controversial. I would go with "use-in-band-status" which is more
>> strictly defined than "autoneg" which could mean anything and everyt=
hing.
>>
>> What do you think?
> I actually think autoneg is a bit better.
>=20
> - Autonegotiation is a widely used and known term:
> https://en.wikipedia.org/wiki/Autonegotiation
> And who knows what in-band status is?

You and I apparently do because otherwise you would not have ran into
this problem and more generally, anyone having some mild exposure to th=
e
(S|R)GMII protocols should at some point, but that is a pointless argum=
ent.

> And, more importantly, who knows what is it used for?
> Who even knows it is used for autonegotiation?

It is not about what do people know most, it is about being accurate an=
d
specific.

>=20
> - When we set autoneg for fixed-link, we basically just
> say "no MDIO here, but please do autoneg by any other
> means, if possible".

I agree with this.

>=20
> - in-band status is an implementation delail, and it is
> specific to a particular protocols. If you request the
> in-band status for some protocol that doesn't support
> it, perhaps you should get -EINVAL, because such a
> config makes no sense. With autonegotiation, the rules
> are not that strict: it can be "unimplemented", which doesn't
> necessary mean nonsense in the config.

So by specifying "autoneg", you are not specific about the kind of
auto-negotiation protocol available, which is precisely my point: you
need to go down to that level of detail for this to be useful. So maybe
something like:

autoneg =3D "in-band-status" would actually be a better thing in terms =
of
description because then you would tell what can be made available/work=
ing?

>=20
> - autonegotiation is a wider term, and may be implemented
> by some other means than the in-band status (which is
> probably impossible for a fixed-link though).
>=20
> - In the terms that the driver uses, it is autonegotiation, eg
> MVNETA_GMAC_AUTONEG_CONFIG. And when you go down
> the implementation details, you see MVNETA_GMAC_INBAND_AN_ENABLE,
> which is just one AN bit of many.

But arguably, there could be another auto-negotiation method, which is
not in-band status related, which means that you would need a way to
distinguish between using in-band status, or using something else or
nothing, would not you?

>=20
> So I really would prefer to keep things as is.
> But if you insist, I can rename, but there will still be no
> -EINVAL checks for obviously wrong configs.


--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>
Subject: Re: [PATCH 2/3] of_mdio: add new DT property 'autoneg' for fixed-link
Date: Sat, 11 Jul 2015 00:02:45 +0300
Message-ID: <55A032F5.8020801@list.ru>
References: <559FF511.5080102@list.ru> <559FF63E.8020209@list.ru>
 <55A010F9.7030808@gmail.com> <55A02656.7020508@list.ru>
 <55A02D90.8090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
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
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55A02D90.8090903-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

10.07.2015 23:39, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> - in-band status is an implementation delail, and it is
>> specific to a particular protocols. If you request the
>> in-band status for some protocol that doesn't support
>> it, perhaps you should get -EINVAL, because such a
>> config makes no sense. With autonegotiation, the rules
>> are not that strict: it can be "unimplemented", which doesn't
>> necessary mean nonsense in the config.
> So by specifying "autoneg", you are not specific about the kind of
> auto-negotiation protocol available, which is precisely my point: you
> need to go down to that level of detail for this to be useful. So may=
be
> something like:
>
> autoneg =3D "in-band-status" would actually be a better thing in term=
s of
> description because then you would tell what can be made available/wo=
rking?
I would agree with this if your argument below is true (see below).

>> - autonegotiation is a wider term, and may be implemented
>> by some other means than the in-band status (which is
>> probably impossible for a fixed-link though).
>>
>> - In the terms that the driver uses, it is autonegotiation, eg
>> MVNETA_GMAC_AUTONEG_CONFIG. And when you go down
>> the implementation details, you see MVNETA_GMAC_INBAND_AN_ENABLE,
>> which is just one AN bit of many.
> But arguably, there could be another auto-negotiation method, which i=
s
> not in-band status related, which means that you would need a way to
> distinguish between using in-band status, or using something else or
> nothing, would not you?
"something else" is a big question here.
Can you think of _any_ other way that is both not an MDIO
(suits to fixed-link) and not an in-band?
If the answer is yes (even theoretically), then
autoneg =3D "in-band" | "off"
may make sense. Otherwise boolean just looks enough.
If we would implement autoneg outside of the fixed-link,
then its semantic would likely be
autoneg =3D "mdio" | "in-band" | "off"
But the fact that we put it under fixed-link where only a
single AN possibility exist, may probably be underlined by
a semantic specific to fixed-link.

One may also argue that
autoneg =3D "any-possible-autoneg-that-works" is better than
specifying it explicitly, which is exactly what the boolean does.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

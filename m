From: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Fri, 27 Mar 2015 19:39:45 +0300
Message-ID: <551587D1.5070408@list.ru>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru> <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

27.03.2015 19:21, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Do you want mvneta to register a similar callback in of_mdio, instea=
d
>> of adding an explicit state-updating functions? Something like
>> of_phy_fixed_link_set_update_callback()?
> You don't need an of_phy_fixed_link_set_update callback, you just nee=
d
> to provide a fixed_link_update callback in mvneta, that you register,
That approach I in fact considered initially, as the simplest one,
and even had a patch. But I disliked the fact that then mvneta will
exploit the knowledge of the fact that of_phy_register_fixed_link()
uses a fixed_phy driver. What if the implementation will later change?
Also what makes me uncomfortable is that since of_phy_register_fixed_li=
nk()
doesn't even return the struct phy_device pointer, mvneta will have
to get around that and use for example of_phy_find_device(), or registe=
r
the callback later, after of_phy_connect(). dsa/slave.c does of_phy_con=
nect()
initially, together with fixed link registration, so it gets around the
problem. But mvneta registers the fixed_link in .probe callback, and
does of_phy_connect() in .open callback.
This all made me to drop that idea despite the simplicity.

>> This will remove a few changes indeed, but perhaps not too much.
>> Please confirm if this is exactly what you want, and then I try.
> Let me know if this is clearer now, if not, I can certainly cook a
> patch which does what I am suggesting. Thanks!
I can do that too, because I already did.
Let me know if the above concerns are not important, and I'll
restore my initial patch.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

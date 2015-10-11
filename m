From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: switchdev and VLAN ranges
Date: Sun, 11 Oct 2015 09:12:09 +0200
Message-ID: <20151011071208.GA2188@nanopsycho.orion>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <BF3B1B92-E7B5-4C49-9B56-FBD36E546F28@mellanox.com>
 <5618EA2A.3020900@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Elad Raz <eladr@mellanox.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Scott Feldman <sfeldma@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36366 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbbJKHMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 03:12:14 -0400
Received: by wicgb1 with SMTP id gb1so114296724wic.1
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 00:12:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5618EA2A.3020900@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 10, 2015 at 12:36:26PM CEST, nikolay@cumulusnetworks.com wrote=
:
>On 10/10/2015 09:49 AM, Elad Raz wrote:
>>=20
>>> On Oct 10, 2015, at 2:30 AM, Vivien Didelot <vivien.didelot@savoirf=
airelinux.com> wrote:
>>>
>>> I have two concerns in mind:
>>>
>>> a) if we imagine that drivers like Rocker allocate memory in the pr=
epare
>>> phase for each VID, preparing a range like 100-4000 would definitel=
y not
>>> be recommended.
>>>
>>> b) imagine that you have two Linux bridges on a switch, one using t=
he
>>> hardware VLAN 100. If you request the VLAN range 99-101 for the oth=
er
>>> bridge members, it is not possible for the driver to say "I can
>>> accelerate VLAN 99 and 101, but not 100". It must return OPNOTSUPP =
for
>>> the whole range.
>>=20
>> Another concern I have with vid_being..vid_end range is the =E2=80=9C=
flags=E2=80=9D. Where flags can be BRIDGE_VLAN_INFO_PVID.
>> There is no sense having more than one VLAN as a PVID.
>> This leave the HW vendor the choice which VLAN id they will use as t=
he PVID.
>>=20
>
>iproute2 doesn't allow to do it but I can see that someone can actuall=
y make it
>so the flags for the range have it and it doesn't look correct. Perhap=
s we need
>something like the patch below to enforce this from kernel-side.
>
>
>diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>index d78b4429505a..02b17b53e9a6 100644
>--- a/net/bridge/br_netlink.c
>+++ b/net/bridge/br_netlink.c
>@@ -524,6 +524,9 @@ static int br_afspec(struct net_bridge *br,
> 			if (vinfo_start)
> 				return -EINVAL;
> 			vinfo_start =3D vinfo;
>+			/* don't allow range of pvids */
>+			if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVID)
>+				return -EINVAL;
> 			continue;
> 		}
>=20

Looks correct to me. Could you please submit this properly? Thanks!

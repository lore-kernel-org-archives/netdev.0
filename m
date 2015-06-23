From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Tue, 23 Jun 2015 10:54:00 +0900
Message-ID: <5588BC38.4060207@miraclelinux.com>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi> <5586F1F8.1070800@universe-factory.net> <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi> <55873C46.4090804@universe-factory.net> <5587A418.4000308@midlink.org> <55884B12.7010307@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	Markus Stenberg <markus.stenberg@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: Matthias Schiffer <mschiffer@universe-factory.net>,
	Steven Barth <steven@midlink.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33395 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbbFWByF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 21:54:05 -0400
Received: by pdjn11 with SMTP id n11so150358734pdj.0
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 18:54:05 -0700 (PDT)
In-Reply-To: <55884B12.7010307@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthias Schiffer wrote:
> On 06/22/2015 07:58 AM, Steven Barth wrote:
>> On 22.06.2015 00:35, Matthias Schiffer wrote:
>>> Could you explain in detail what you mean with "If you want specifi=
c SA,
>>> add same route with higher metric and/or (more) specific src match.=
"?
>>> Routes aren't bound to specific addresses except via the "src" attr=
ibute
>>> (which is called prefsrc in the kernel), which is exactly what it n=
ot
>>> working. I can't control the chosen source address at all when
>>> source-specific routes are involved.
>> Except that prefsrc and src are two different beasts and usually ip =
route from transates to
>> RTA_SRC instead of RTA_PREFSOURCE when used with a prefix length.
>>
>> Try adding two routes to the same destination with the same metric b=
ut different source values with PREFSRC (e.g. IPv4) and then
>> try doing the same with SRC (e.g. IPv6). The former will fail but th=
e latter will succeed.
>=20
> Ah sorry, I didn't know that "src" and "prefsrc" were distinct concep=
ts.
> I meant to refer to "src" whenever I wrote "prefsrc". What are the
> precise semantics of the "src" attribute? Any RFC I can read, or is t=
his
> a Linux-specific concept?
>=20

"src" is long-lived feature which is usually used with mutiple routing
tables by "ip rule".

--yoshfuji

>>
>>
>> https://tools.ietf.org/html/draft-troan-homenet-sadr-01
>> was the original draft for source-address dependent routing IIRC so =
might be a good read.
>=20
> Thanks for the link, that helps a bit.
>=20
>>
>>
>>>
>>> Even though the source-specific route has a higher metric than the
>>> generic one, the source-specific one shadows the generic route.
>>
>> (was a bit ago since I read into this so please correct me if I am w=
rong)
>> IIRC this is intentional since longest-prefix-match beats metric her=
e
>> and the source-address match counts to being more-specific here. See=
 also above difference between PREFSRC and SRC.
>=20
> Ah, that would explain the metric issue. I looks like the source of m=
y
> confusion is that for source-specific routes *all* addresses are in t=
he
> candidate set, not only the addresses of the outgoing interface (whic=
h
> makes sense as ip6_route_get_saddr() is called with a NULL rt6_info i=
n
> the source-specific case).
>=20
> I'm not sure if this can be fixed in a sane way (as there seems to be=
 a
> dependency cycle: source address should depend on outgoing interface,
> which depends on the chosen route, which depends on the source addres=
s),
> but it leads to highly unintuitive source address selection :(
>=20
> Markus suggested in the commit message not to call ip6_route_output a=
t
> all before the source address has been selected. Wouldn't this make i=
t
> impossible to choose the source address depending on the outgoing
> interface in the non-source-specific case as well?
>=20
>> Cheers,
>>
>> Steven
>=20
> Thanks for the explanation,
> Matthias
>=20

--=20
=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.co=
m>
=E3=83=9F=E3=83=A9=E3=82=AF=E3=83=AB=E3=83=BB=E3=83=AA=E3=83=8A=E3=83=83=
=E3=82=AF=E3=82=B9=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE =E6=8A=80=E8=A1=93=
=E6=9C=AC=E9=83=A8 =E3=82=B5=E3=83=9D=E3=83=BC=E3=83=88=E9=83=A8

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Interface group match - netfilter part
Date: Wed, 17 Oct 2007 11:11:12 +0200
Message-ID: <4715D1B0.30209@trash.net>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu> <11925217031728-git-send-email-panther@balabit.hu> <47147692.8070709@trash.net> <4715D117.3080405@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4715D117.3080405@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Patrick McHardy =EDrta:
>
>> The input interface is only valid in PREROUTING, INPUT and FORWARD.
>> Why don't you support output-interface matching?
>>
>=20
> The new version supports output-interface, currently I'm rewriting=20
> iptables part. But I'm not sure what to do with the forward chain=20
> because both input and output interface are valid here. My idea is th=
at=20
> the ifgroup_match function checks ifgroup values of both input and=20
> output interfaces if they are set. An example:
>=20
> iptables -A FORWARD -m ifgroup --in-ifgroup 4 --out-ifgroup 5/0x0f -j=
=20
> ACCEPT
>=20
> The packet's input interface must be in group 4 and output interface=20
> must be in group 5 but only lower 4 bits are checked. If one of these=
=20
> assumptions fails the match fails.
>=20
> Is it ok, or only one of them should be checked as in xt_policy: if=20
> input side matches, other one is not checked?


xt_policy is a special case because the policy structure is so
large I decided the user should better use the match twice if
he really needs it (its also a quite uncommon use). For the
ifgroup match I think it should behave exactly as the -i and -o
matches: allow matching both in FORWARD, input device in
PREROUTING and INPUT and output device in OUTPUT and POSTROUTING.
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

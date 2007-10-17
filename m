From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 2/2] Interface group match - netfilter part
Date: Wed, 17 Oct 2007 11:08:39 +0200
Message-ID: <4715D117.3080405@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu> <11925217031728-git-send-email-panther@balabit.hu> <47147692.8070709@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:45058 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753674AbXJQJIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 05:08:42 -0400
In-Reply-To: <47147692.8070709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> +static int match(const struct sk_buff *skb,
>> +      const struct net_device *in,
>> +      const struct net_device *out,
>> +      const struct xt_match *match,
>> +      const void *matchinfo,
>> +      int offset,
>> +      unsigned int protoff,
>> +      int *hotdrop)
>> +{
>> +    const struct xt_ifgroup_info *info =3D matchinfo;
>> +
>> +    return ((in->ifgroup & info->mask) =3D=3D info->group) ^ info->=
invert;
>=20
> The input interface is only valid in PREROUTING, INPUT and FORWARD.
> Why don't you support output-interface matching?
>=20

The new version supports output-interface, currently I'm rewriting=20
iptables part. But I'm not sure what to do with the forward chain=20
because both input and output interface are valid here. My idea is that=
=20
the ifgroup_match function checks ifgroup values of both input and=20
output interfaces if they are set. An example:

iptables -A FORWARD -m ifgroup --in-ifgroup 4 --out-ifgroup 5/0x0f -j A=
CCEPT

The packet's input interface must be in group 4 and output interface=20
must be in group 5 but only lower 4 bits are checked. If one of these=20
assumptions fails the match fails.

Is it ok, or only one of them should be checked as in xt_policy: if=20
input side matches, other one is not checked?

--=20
Attila

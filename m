From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bloat] shaper team forming up
Date: Mon, 14 Mar 2011 21:24:37 +0100
Message-ID: <1300134277.2649.19.camel@edumazet-laptop>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org>
	 <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave =?ISO-8859-1?Q?T=E4ht?= <d@taht.net>,
	bloat-devel <bloat-devel@lists.bufferbloat.net>,
	bloat <bloat@lists.bufferbloat.net>,
	netdev <netdev@vger.kernel.org>
To: Jonathan Morton <chromatix99@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57527 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab1CNUYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:24:41 -0400
Received: by fxm17 with SMTP id 17so3327927fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 13:24:40 -0700 (PDT)
In-Reply-To: <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 21:55 +0200, Jonathan Morton a =C3=A9crit =
:
> On 14 Mar, 2011, at 9:26 pm, Dave T=C3=A4ht wrote:
>=20
> > Over the weekend, Dan Siemons uncovered a possible bad interaction
> > between ECN and the default pfifo_fast qdisc in Linux.
> >=20
> > http://www.coverfire.com/archives/2011/03/13/pfifo_fast-and-ecn/
>=20
> This seems to be more complicated that it appears.  It looks as thoug=
h
> Linux has re-used the LSB of the old TOS field for some "link local"
> flag which is used by routing.
>=20
> It's not immediately obvious whether pfifo_fast is using this new
> interpretation though.  If it isn't, the fix should be to remove the
> RTO_ONLINK bit from the mask it's using on the tos field.  The other
> half of the mask correctly excludes the ECN bits from the field.
>=20

CC netdev, where linux network dev can take a look.

I would say that this is a wrong analysis :=20

1) ECN uses two low order bits of TOS byte

2) pfifo_fast uses skb->priority


skb->priority =3D rt_tos2priority(iph->tos);

#define IPTOS_TOS_MASK            0x1E
#define IPTOS_TOS(tos)            ((tos)&IPTOS_TOS_MASK)

static inline char rt_tos2priority(u8 tos)
{
	return ip_tos2prio[IPTOS_TOS(tos)>>1];
}

No interference between two mechanisms, unless sysadmin messed up thing=
s
(skb_edit)




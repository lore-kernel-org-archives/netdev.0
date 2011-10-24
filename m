From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Flow classifier proto-dst and TOS (and proto-src)
Date: Mon, 24 Oct 2011 06:02:11 +0200
Message-ID: <1319428931.2517.28.camel@edumazet-laptop>
References: <1318697463.7169.21.camel@ganymede>
	 <1318831799.2500.25.camel@edumazet-laptop>
	 <1319418232.20602.16.camel@ganymede>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dan Siemon <dan@coverfire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34527 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab1JXECP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 00:02:15 -0400
Received: by wyg36 with SMTP id 36so5721263wyg.19
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 21:02:14 -0700 (PDT)
In-Reply-To: <1319418232.20602.16.camel@ganymede>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 23 octobre 2011 =C3=A0 21:03 -0400, Dan Siemon a =C3=A9crit=
 :
> On Mon, 2011-10-17 at 08:09 +0200, Eric Dumazet wrote:
> > Le samedi 15 octobre 2011 =C3=A0 12:51 -0400, Dan Siemon a =C3=A9cr=
it :
> > > cls_flow.c: flow_get_proto_dst()
> > >=20
> > > The proto-dst key returns the destination port for UDP, TCP and a=
 few
> > > other protocols [see proto_ports_offset()]. For ICMP and IPIP it =
falls
> > > back to:
> > >=20
> > > return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
> > >=20
> > > Since Linux maintains a dst_entry for each TOS value this causes =
the
> > > returned value to be affected by the TOS which is unexpected and
> > > probably broken.
> >=20
> > Hi Dan
> >=20
> > I think Patrick did this on purpose, because of of the lack of
> > perturbation in cls_flow.c : If all these frames were mapped to a s=
ingle
> > flow, they might interfere with an other regular flow and hurt it.
> >=20
> > I dont qualify existing code as buggy. Its about fallback behavior
> > anyway (I dont think its even documented)
>=20
> Thanks for the review Eric.
>=20
> Won't virtually all uses of proto-dst also use the dst key anyway? In
> which case this fallback does nothing except make the TOS effect the
> hash output because the dst will be the same and dst_entry would be t=
he
> same if it wasn't for the different TOS (by far the common case). I
> don't see the value of the unintuitive behavior.
>=20
> I'm not certain this is a problem but also note that including TOS wi=
ll
> mean that packets within a tunnel will be reordered if 'tos inherit' =
is
> set on the tunnel and only the typical src,dst,proto,proto-src,proto-=
dst
> is used. Again, probably not expected.

Hmm, it seems cls_flow now supports "perturbation", so my prior argumen=
t
is not true anymore. I guess your patch would be fine, but I prefer
waiting Patrick review on it ;)

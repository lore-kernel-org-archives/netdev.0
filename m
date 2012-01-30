From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Improved handling of IPv6 atomic fragments (FO=0, MF=0)
Date: Mon, 30 Jan 2012 11:47:57 +0100
Message-ID: <1327920477.2288.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F266FD6.4070301@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: security@kernel.org, netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:61726 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752008Ab2A3KsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 05:48:02 -0500
Received: by lagu2 with SMTP id u2so2099757lag.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 02:48:00 -0800 (PST)
In-Reply-To: <4F266FD6.4070301@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 janvier 2012 =C3=A0 07:24 -0300, Fernando Gont a =C3=A9crit=
 :
> Folks,
>=20
> FYI. We have published an IETF I-D that proposes an improved handling=
 of
> IPv6 atomic fragments (IPv6 fragments that have an offset of 0, and M=
=46=3D0).
>=20
> The I-D is available here:
> <http://tools.ietf.org/id/draft-gont-6man-ipv6-atomic-fragments-00.tx=
t>
>=20
> The aforementioned behaviour eliminates fragmentation-based attacks
> against traffic that employs atomic fragments, and has already been
> implemented by OpenBSD.
>=20
> Thanks,

Unless I missed something, linux already does that.

ipv6_frag_rcv()

        if (!(fhdr->frag_off & htons(0xFFF9))) {
                /* It is not a fragmented frame */
                skb->transport_header +=3D sizeof(struct frag_hdr);
                IP6_INC_STATS_BH(net,
                                 ip6_dst_idev(skb_dst(skb)), IPSTATS_MI=
B_REASMOKS);

                IP6CB(skb)->nhoff =3D (u8 *)fhdr - skb_network_header(s=
kb);
                return 1;
        }

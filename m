From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 06/10] e1000e: Support for byte queue limits
Date: Thu, 01 Dec 2011 17:40:09 +0100
Message-ID: <1322757609.29414.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111281819350.24413@pokey.mtv.corp.google.com>
	 <20111129130137.000009ce@unknown>
	 <CA+mtBx-8AzEyUc3GVD+mEQoqUZeaB9hjSJonRW_SjOQaTx51mQ@mail.gmail.com>
	 <1322734334.2335.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CA+mtBx80aoWtDh3=gMnfVCi9r5E_bjqgreoa-yjwDc5+kcocjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49428 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755251Ab1LAQkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 11:40:14 -0500
Received: by faaq16 with SMTP id q16so1457052faa.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 08:40:12 -0800 (PST)
In-Reply-To: <CA+mtBx80aoWtDh3=gMnfVCi9r5E_bjqgreoa-yjwDc5+kcocjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 08:32 -0800, Tom Herbert a =C3=A9=
crit :
> > OK, as stated on your other thread, its obvious this driver (and
> > probably other intel drivers) made assumptions that are now obsolet=
e,
> > since skb head can contain some data payload, not only (MAC+IP+TCP)
> > headers.
> >
> Looks like similar is in several Intel drivers.  Only other driver I
> found that is using the false assumption is tg3 IPv6 gso path.
>=20
> > If Intel guys cannot afford approximate the bytecount by skb->len, =
I
> > suggest to use same trick found in
> > drivers/net/ethernet/intel/igb/igb_main.c
> >
> > static int igb_tso(struct igb_ring *tx_ring,
> > ...
> >        /* compute header lengths */
> >        l4len =3D tcp_hdrlen(skb);
> >        *hdr_len =3D skb_transport_offset(skb) + l4len;
> >
> I noticed a similar technique used by several drivers.  it's fine if
> it already knew the packet was TCP.  Just assuming that a GSO packet
> is TCP might be a new bug, so in the e1000e driver they would need to
> check the type (gso_type =3D=3D SKB_GSO_TCPV4 or SKB_GSO_TCPV6).
>=20
> I'm not sure that tcp_hdrlen is even being used correctly in the othe=
r
> drivers.  For instance in bnx2x, tcp_hdrlen is called after checking
> skb_is_gso_v6(skb) and skb_is_gso(skb).  If the former is true then i=
n
> fact it is a TCP packet (gso_type is SKB_GSO_TCPV6) , but the if the
> latter is true it only proves that is is GSO packet (gso_type not
> checked, only gso_size>0)--  the packet might be a fragment UDP packe=
t
> for instance, so tcphdr_len is not valid on those skbs.

To my knowledge, only one NIC (neterion/s2io) supports NETIF_F_UFO.

So all others only receive tcp gso frames.

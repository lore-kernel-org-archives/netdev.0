From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Sun, 13 Nov 2011 22:08:15 +0200
Message-ID: <1321214895.3101.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1320673364.3020.21.camel@bwh-desktop>
 <1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111109.163708.2156133928191684256.davem@davemloft.net>
 <1320876183.3272.8.camel@edumazet-laptop>
 <1320884940.5825.34.camel@edumazet-laptop>
 <1320937526.307.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <1320938878.2310.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1320942423.307.10.camel@lb-tlvb-eilong.il.broadcom.com>
 <1320943512.10042.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1321210419.3101.1.camel@lb-tlvb-eilong.il.broadcom.com>
 <1321213338.17837.38.camel@edumazet-laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1093 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169Ab1KMUIe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:08:34 -0500
In-Reply-To: <1321213338.17837.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-11-13 at 11:42 -0800, Eric Dumazet wrote:
> Le dimanche 13 novembre 2011 =C3=A0 20:53 +0200, Eilon Greenstein a =C3=
=A9crit :
>=20
> > I=E2=80=99m not sure I=E2=80=99m following the math over here. Assu=
ming L1 is 64 bytes,
> > we need up to 63 bytes to align the start address (assuming SLOB is
> > being used) and additional (up to) 63 bytes at the end. That can su=
m up
> > to 126 bytes  am I missing something?
> >=20
>=20
> What do you really mean by aligning the end ?

I mean padding it to full cache line.

> How can both start and end of a frame can be aligned ?

The packet will start at aligned address and (using padding) will end a=
t
cache line boundaries.

> If hardware needs extra room after the end of frame, then we already
> have it (since we store struct skb_shared_info here)

We have some space in there, but as far as I can tell it's not up to 63
bytes, right? We will overrun the dataref.

Thanks,
Eilon

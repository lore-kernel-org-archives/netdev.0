From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Wed, 25 Aug 2010 14:17:43 +0200
Message-ID: <1282738663.2487.207.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	 <20100823080543.319143e3@nehalam>
	 <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
	 <1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
	 <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
	 <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510>
	 <1282715698.2467.681.camel@edumazet-laptop>
	 <20100825121058.GA28498@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Marc Aurele La France <tsi@ualberta.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41220 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab0HYMRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 08:17:48 -0400
In-Reply-To: <20100825121058.GA28498@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 16:10 +0400, Alexey Kuznetsov a =C3=
=A9crit :
> Hello!
>=20
> > It is, but ip_append_data() is allocating a huge head if MTU is hug=
e.
>=20
> Hmm, strange, as I remember, it was supposed to work right.
>=20
> If the device supports SG (which is required to accept non-linear skb=
s anyway),
> then ip_append_* should allocate skbs not rounded up to mtu and we sh=
ould
> allocate small skb with NFS header only. Does not it work?
>=20
> I can only guess one possible trap: people could do _one_ huge ip_app=
end_data()
> (instead of "planned" scenario, when the header is sent with ip_appen=
d_data()
> and the following payload is appended with ip_append_page()). Huge ip=
_append_data()
> will generate huge skb indeed. Is this the problem?
>=20
>=20
> BTW this issue could be revisited and this "will generate huge" can b=
e reconsidered.
> Automatic generation of fragmented skbs was deliberately suppressed, =
because it was
> found that all devices existing at the moment when this code was writ=
ten
> are strongly biased against SG. Current code tries to _avoid_ generat=
ing
> non-linear skbs, unless it is intended for zero-copy, which compensat=
ed
> bias against SG. Modern hardware should work better.
>=20
> Alexey

Hi Alexey,

=46ew hours ago, I privately asked to Marc Aurele if its infiniband dev=
ice
was supporting NETIF_F_SG in its features ;)

Thanks !



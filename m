From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding sessions
Date: Tue, 03 Dec 2013 11:37:04 +0100
Message-ID: <2526311.Qy2u417McY@h2o.as.studentenwerk.mhn.de>
References: <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com> <20131201.203506.1790384137281236147.davem@davemloft.net> <20131203095645.GS31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mschiffer@universe-factory.net,
	stable@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:59346 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752905Ab3LCKhH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 05:37:07 -0500
In-Reply-To: <20131203095645.GS31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 3. Dezember 2013, 10:56:45 schrieb Steffen Klassert:
> Ccing stable.
>=20
> On Sun, Dec 01, 2013 at 08:35:06PM -0500, David Miller wrote:
> > From: Matthias Schiffer <mschiffer@universe-factory.net>
> > Date: Sun, 01 Dec 2013 05:19:53 +0100
> >=20
> > > On 11/24/2013 03:27 PM, Matthias Schiffer wrote:
> > >> On 11/01/2013 09:21 AM, Steffen Klassert wrote:
> > >>> On some codepaths the skb does not have a dst entry
> > >>> when xfrm_decode_session() is called. So check for
> > >>> a valid skb_dst() before dereferencing the device
> > >>> interface index. We use 0 as the device index if
> > >>> there is no valid skb_dst(), or at reverse decoding
> > >>> we use skb_iif as device interface index.
> > >>>=20
> > >>> Bug was introduced with git commit bafd4bd4dc
> > >>> ("xfrm: Decode sessions with output interface.").
> > >>>=20
> > >>> Reported-by: Meelis Roos <mroos@linux.ee>
> > >>> Tested-by: Meelis Roos <mroos@linux.ee>
> > >>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > >>=20
> > >> Please queue this for 3.12-stable, I've seen this bug trigger a =
panic
> > >> when heavily using Bittorrent (screenshot:
> > >> http://i.imgur.com/OIKVccM.jpg )
> > >>=20
> > >> Thanks,
> > >> Matthias
> > >=20
> > > Ping? Several people I know have hit this panic with 3.12.x at le=
ast
> > > once or twice by now during heavy IPv6 usage.
> >=20
> > Steffen submitted it to stable@vger.kernel.org for inclusion on Mon=
day
> > November 25th.
>=20
> It apparently did not make it into v3.12.2 and it is not in the v3.12=
=2E3
> review included. So I wonder if I need to do anything additional to
> get it included. It is the first time that I did a stable submission
> myself.
>=20
> I tried to follow the instructions at Documentation/stable_kernel_rul=
es.txt
> but maybe I've missed something.

There is another weakness with ipv6 in 3.12.x which - under certain=20
circumstances - can be exploited remotely:

	ipv6 fragmentation-related panic in netfilter

I would be very glad if this would make it into 3.12 stable soon.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

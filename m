From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.12+
Date: Mon, 08 Dec 2014 23:20:42 +0100
Message-ID: <5642727.qTG53DqrAk@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <1841985.3SsQX9ZHP0@h2o.as.studentenwerk.mhn.de> <1417785985.4322.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:42119 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752540AbaLHWUp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 17:20:45 -0500
In-Reply-To: <1417785985.4322.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 5. Dezember 2014, 05:26:25 schrieb Eric Dumazet:
> On Fri, 2014-12-05 at 13:09 +0100, Wolfgang Walter wrote:
> > Hello,
> >=20
> > as reverting this patch fixes this rather annoying problem: is it
> > dangerous to revert it as a workaround until the root cause is foun=
d?
>=20
> Unfortunately no, this patch fixes a serious issue.
>=20
> We need to find the root cause of your problem instead of trying to w=
ork
> around it.
>=20

I only wanted to use it as local workaround here.


I looked a bit at at code. I'm not familiar with the network code, thou=
gh :-).

When exactly should the gso handling with esp tunnel mode happen?

esp_output_done() calls xfrm_output_resume() and no gso handling is don=
e.=20
Would be to late anyway.
esp_output() does not handle gso.
xfrm4_mode_tunnel_output() does not do any gso handling as far as I can=
 see.

xfrm_output() (from net/xfrm/xfrm_output) does but is it called with es=
p=20
tunnel mode?

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: possible issue between bridge igmp/multicast  handling & bnx2x
 on kernel 2.6.34 and >
Date: Fri, 07 Jan 2011 12:28:25 +0100
Message-ID: <1294399705.3306.8.camel@edumazet-laptop>
References: <4D23234E.30709@univ-nantes.fr>
	 <4D26EDA4.7060502@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:57272 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab1AGL2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 06:28:30 -0500
Received: by wwi17 with SMTP id 17so354636wwi.1
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 03:28:29 -0800 (PST)
In-Reply-To: <4D26EDA4.7060502@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 janvier 2011 =C3=A0 11:40 +0100, Yann Dupont a =C3=A9cri=
t :
> Le 04/01/2011 14:40, Yann Dupont a =C3=A9crit :
> ...
> > We just added BCM57711 10G cards (bnx2x driver) on our blade server=
s=20
> > (connected to 10G Power Connect M8024).
> > Since then, we are experiencing random lost of packets.
> >
> > Symptom : packets are lost on some vlans for a few seconds, then=20
> > things go back to normal (and stops again a few minutes later)
> >
>=20
> As I didn't had answer so far , I digged a little more and captured m=
ore=20
> packets.
> I just noticed that an event trigger that problem : IPv6 neighbor=20
> discovery packet .
>=20
> This is , of course, a multicast packet.
>=20
> Just saw that 2.6.36.3 should include this fix :
>=20
> > From: David Stevens<dlstevens@us.ibm.com>
> >
> > [ Upstream commit 04bdf0c9a451863e50fff627713a900a2cabb998 ]
> >
> > This patch fixes a missing ntohs() for bridge IPv6 multicast snoopi=
ng.
> But in fact , I just tested, and this doesn't cure the problem :(
>=20
> This bug
> - only occurs with bnx2x with tagged vlans, attached to bridges. Othe=
r=20
> interfaces (bnx2 , for exemple) works fine. bnx2x without bridges wor=
ks=20
> fine.
> - only happens when bridge is compiled with CONFIG_BRIDGE_IGMP_SNOOPI=
NG=20
> (default setting)
> - is triggered by IPv6 neighbor discovery packet. Just after that=20
> packet, others packets are discarded for some time.
> - packets originating from same vlans are not affected, only packets=20
> previously routed are discarded. Examinating those packets, I don't=20
> undersand why, apart TTL (and mac address), they seems similar .
> - has origin circa 2.6.33 :
> fe2d7c70b747d5d968f4e8fa210676d49d40059 is the first bad commit
> commit 3fe2d7c70b747d5d968f4e8fa210676d49d40059
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Sun Feb 28 00:49:38 2010 -0800
>=20
>      bridge: Add multicast start/stop hooks
>=20
>      This patch hooks up the bridge start/stop and add/delete/disable
>      port functions to the new multicast module.
>=20
>      Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
>=20
> What can I do to help fixing this bug ?
> regards,
>=20

Please take a look at whole thread at
https://lkml.org/lkml/2010/8/13/200

I guess this is a similar problem.




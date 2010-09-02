From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 02 Sep 2010 14:09:09 +0200
Message-ID: <1283429349.2454.496.camel@edumazet-laptop>
References: <20100830.095012.233695092.davem@davemloft.net>
	 <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local>
	 <20100901.145151.93454549.davem@davemloft.net>
	 <20100902083327.GA6246@ff.dom.local>
	 <1283419909.2454.137.camel@edumazet-laptop>
	 <20100902095502.GA8775@ff.dom.local>
	 <1283424105.2454.311.camel@edumazet-laptop>
	 <20100902110212.GB8775@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60405 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab0IBMJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 08:09:14 -0400
Received: by wyb35 with SMTP id 35so189089wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 05:09:12 -0700 (PDT)
In-Reply-To: <20100902110212.GB8775@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 11:02 +0000, Jarek Poplawski a =C3=A9=
crit :
> On Thu, Sep 02, 2010 at 12:41:45PM +0200, Eric Dumazet wrote:

> > Two vlans might carry packets in different domains, with a clash of=
 IP
> > space and TCP flows. Even with a probability of 0.000000001%, we ca=
nnot
> > ever merge two packets of different domains. Really !
>=20
> Hmm... But there is only a question of sky2 and this test in
> __napi_gro_receive().
>=20

Any driver can receive in one napi run :

1) A TCP tagged frame for vlan 345, delivered to vlan_gro_receive(),
queued in napi->gro_list.

2) An untagged frame, delived via napi_gro_receive()
    Can meet previous frame in napi->gro_list. Should not merge.

So napi_gro_receive() must perform the same skb->dev check, sky2 or not=
=2E

> >=20
> > napi->dev is not used in GRO path, as mentioned earlier,
> > but in napi_get_frags(), while not needed.
> >=20
> > To make this very clear, I suggest following patch :
>=20
> But where this skb gets its skb->dev now?

Oh you are right, I thought drivers were setting this later, but its no=
t
the case.




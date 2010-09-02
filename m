From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 2 Sep 2010 12:28:58 +0000
Message-ID: <20100902122858.GC8775@ff.dom.local>
References: <20100830.095012.233695092.davem@davemloft.net> <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local> <20100901.145151.93454549.davem@davemloft.net> <20100902083327.GA6246@ff.dom.local> <1283419909.2454.137.camel@edumazet-laptop> <20100902095502.GA8775@ff.dom.local> <1283424105.2454.311.camel@edumazet-laptop> <20100902110212.GB8775@ff.dom.local> <1283429349.2454.496.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37248 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab0IBM3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 08:29:07 -0400
Received: by fxm13 with SMTP id 13so143520fxm.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 05:29:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283429349.2454.496.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 02:09:09PM +0200, Eric Dumazet wrote:
> Le jeudi 02 septembre 2010 ?? 11:02 +0000, Jarek Poplawski a =E9crit =
:
> > On Thu, Sep 02, 2010 at 12:41:45PM +0200, Eric Dumazet wrote:
>=20
> > > Two vlans might carry packets in different domains, with a clash =
of IP
> > > space and TCP flows. Even with a probability of 0.000000001%, we =
cannot
> > > ever merge two packets of different domains. Really !
> >=20
> > Hmm... But there is only a question of sky2 and this test in
> > __napi_gro_receive().
> >=20
>=20
> Any driver can receive in one napi run :
>=20
> 1) A TCP tagged frame for vlan 345, delivered to vlan_gro_receive(),
> queued in napi->gro_list.
>=20
> 2) An untagged frame, delived via napi_gro_receive()
>     Can meet previous frame in napi->gro_list. Should not merge.
>=20
> So napi_gro_receive() must perform the same skb->dev check, sky2 or n=
ot.

But of course!!! I was mislead by Stephen's changelog so much. So now
I really can't understand this current: "sky2: don't do GRO on second
port"...

Thanks,
Jarek P.

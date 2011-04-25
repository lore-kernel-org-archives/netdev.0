From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Mon, 25 Apr 2011 14:27:48 +0200
Message-ID: <1303734468.2747.120.camel@edumazet-laptop>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
	 <4DAD76F1.40309@monstr.eu>
	 <45cb2254ff23a4977c95b0f9459e39a6.squirrel@www.liukuma.net>
	 <4DAFE4A0.2030905@monstr.eu> <1303373925.3685.6.camel@edumazet-laptop>
	 <4DB55876.2010008@monstr.eu> <1303733669.2747.115.camel@edumazet-laptop>
	 <4DB5668B.8020808@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: juice@swagman.org, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47807 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab1DYM1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 08:27:52 -0400
Received: by wya21 with SMTP id 21so1501693wya.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 05:27:51 -0700 (PDT)
In-Reply-To: <4DB5668B.8020808@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 14:18 +0200, Michal Simek a =C3=A9crit :

> >=20
> > Now, if all you want to do is send many packets from pktgen (with o=
nly
> > ID changing), you could add a fast path to not rebuild from scratch=
 new
> > packets.
>=20
> What do you mean?


If you know your device has X slots in its TX ring buffer, you would
have to maintain at least X+1 skbs in pktgen to make sure you reuse an
skb while its previous logical content was sent on wire.

Then you are free to only change iph->id and iph->check very fast.





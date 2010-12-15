From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 18:09:40 +0100
Message-ID: <1292432980.3427.369.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>
	 <1292432120.3427.366.camel@edumazet-laptop>  <4D08F4F4.3050501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50002 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab0LORJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 12:09:45 -0500
Received: by wwa36 with SMTP id 36so1526063wwa.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 09:09:44 -0800 (PST)
In-Reply-To: <4D08F4F4.3050501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 18:03 +0100, Patrick McHardy a=
 =C3=A9crit :

> Right, that's odd. It shouldn't be necessary anymore though since
> now we initialize allot in sfq_enqueue() for all new flows and
> increase allotment for all active flows once per round in sfq_dequeue=
().
> The above code causes a second increase for the flow following a flow
> which went inactive.

Well, we do this in three places. Each time we 'select' a flow as the
next packet provider, we increase its allot by quantum.

We could change this, adding quantum to the current slot when its allot
becomes negative (and we select the next slot for next round)

This basically was what my V1 was doing ;)




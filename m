From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC]: soreuseport: Bind multiple sockets to same port
Date: Mon, 19 Apr 2010 19:16:58 +0200
Message-ID: <1271697418.3845.92.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004182321480.1822@pokey.mtv.corp.google.com>
	 <1271662103.16881.7300.camel@edumazet-laptop>
	 <m2z65634d661004190838hd16ab01dpa074ce6aeb3572e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:52019 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab0DSRRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 13:17:04 -0400
Received: by bwz25 with SMTP id 25so5874015bwz.28
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 10:17:03 -0700 (PDT)
In-Reply-To: <m2z65634d661004190838hd16ab01dpa074ce6aeb3572e8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 08:38 -0700, Tom Herbert a =C3=A9crit :

> Calling it a nightmare be be a little strong.  It is true that this
> could create long chains that need to be walked, but this might be
> done with good cache locality of the structures.  In any case, the
> lock contention seems to overshadow the cost of this; we were able to
> increase max number of DNS queries/sec by about 60% (I will try to
> publish some numbers this week).
>=20

I have no doubt this patch increases performances, but I think its not =
a
long term solution. We can do better ;)


> >
> I agree that CPU awareness is desirable, but I'm really hesitant to
> resort to pinning; this can become pretty tangled on a shared server
> running a bunch of different applications-- would be nice if the
> kernel can just figure out the right thing to do :-)
>=20

OK I can understand this, but please use an array of sockets bound to
same tuple, so that lookup stay constant, regardless of number of
sockets. UDP fast path is a sensible area for financial applications.

Once anchor is found in normal udp hashtable, the choice of a random
target in its array is O(1) too (you could use skb->rxhash if not null)

Hmm, maybe we even could use same mechanism for multicast, since we
currently perform a very expensive loop.




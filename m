From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: More prefetch fall-out
Date: Sun, 22 May 2011 20:23:46 +0200
Message-ID: <1306088626.12435.27.camel@edumazet-laptop>
References: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41025 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab1EVSXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 14:23:52 -0400
Received: by wwa36 with SMTP id 36so5515779wwa.1
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 11:23:51 -0700 (PDT)
In-Reply-To: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 22 mai 2011 =C3=A0 10:49 -0700, Linus Torvalds a =C3=A9crit=
 :

> However, one of the breakages is <linux/skbuff.h> that does its own
> list-walking functions ("skb_queue_walk*"), and they do prefetching.
> So now I have the option to either just add <linux/prefetch.h> to tha=
t
> file, or remove the prefetches. And you're the one that said that the
> prefetches in the networking code were annoying.
>=20
> So should the skb queues use prefetching? I have a hard time judging.
> Are those lists usually long? Is the loop usually large enough that
> there is any point to prefetching the next entry?
>=20

Taking a look at various skb_queue_walk* call sites, I think prefetches
are not a clear win, I would just remove them all from skbuff.h

BTW, the skb_queue_walk_safe(), skb_queue_walk_from_safe(),
skb_queue_reverse_walk_safe, skb_queue_reverse_walk_from_safe() dont
have prefetch() calls.




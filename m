From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Mon, 26 Apr 2010 08:09:14 +0200
Message-ID: <1272262154.2069.1032.camel@edumazet-laptop>
References: <1272252016-11755-1-git-send-email-xiaosuo@gmail.com>
	 <1272258841.2069.968.camel@edumazet-laptop>
	 <q2w412e6f7f1004252244s3a5000eft850c2a5dc0fd72d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58338 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964Ab0DZGJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 02:09:19 -0400
Received: by bwz19 with SMTP id 19so140808bwz.21
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 23:09:17 -0700 (PDT)
In-Reply-To: <q2w412e6f7f1004252244s3a5000eft850c2a5dc0fd72d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 avril 2010 =C3=A0 13:44 +0800, Changli Gao a =C3=A9crit :
> On Mon, Apr 26, 2010 at 1:14 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 26 avril 2010 =C3=A0 11:20 +0800, Changli Gao a =C3=A9crit=
 :
> >> reimplement completion_queue as a FIFO queue.
> >>
> >> As slab allocator always does its best to return the latest unused=
 objects, we'd
> >> better release skb in order, this patch reimplement completion_que=
ue as a FIFO
> >> queue instead of the old LIFO queue.
> >
> >
> > 1) New devices dont use completion queue.
>=20
> It is good enough reason for rejection.
>=20

I said, this part of the kernel is not used today.

> >
> > 2) Hot objects are the last enqueued.
> >   If many objects were queued, the old one are not hot anymore.
> >
> >   Using FIFO will give more cache misses, when walking the chain
> > (skb->next)
> >
>=20
> I meaned that slab allocator maintains objects in the LIFO manner, an=
d
> if we call kmem_cache_alloc(cache) after a kmem_cache_free(cache)
> call, the last object freed by kmem_cache_free(cache) will be
> returned, as this object are more likely in cache and hot. If we don'=
t
> realse skbs in FIFO manner, the last and hot one will not been
> returned at first.
>=20

But your patch doesnt change this behavior. This is irrelevant.

LIFO is the slub behavior, for the exact reason its better for cache
reuse. Same for completion queue.

I repeat :=20
- slub dont touch objects in normal situations.
- LIFO is better for caches.
- LIFO is faster (one pointer for the queue head)



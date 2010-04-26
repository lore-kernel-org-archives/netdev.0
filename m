From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Mon, 26 Apr 2010 13:44:36 +0800
Message-ID: <q2w412e6f7f1004252244s3a5000eft850c2a5dc0fd72d1@mail.gmail.com>
References: <1272252016-11755-1-git-send-email-xiaosuo@gmail.com>
	<1272258841.2069.968.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:55160 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab0DZFo5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 01:44:57 -0400
Received: by iwn8 with SMTP id 8so4662789iwn.16
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 22:44:56 -0700 (PDT)
In-Reply-To: <1272258841.2069.968.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 26, 2010 at 1:14 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 26 avril 2010 =C3=A0 11:20 +0800, Changli Gao a =C3=A9crit :
>> reimplement completion_queue as a FIFO queue.
>>
>> As slab allocator always does its best to return the latest unused o=
bjects, we'd
>> better release skb in order, this patch reimplement completion_queue=
 as a FIFO
>> queue instead of the old LIFO queue.
>>
>
> 1) New devices dont use completion queue.

It is good enough reason for rejection.

>
> 2) Hot objects are the last enqueued.
> =C2=A0 If many objects were queued, the old one are not hot anymore.
>
> =C2=A0 Using FIFO will give more cache misses, when walking the chain
> (skb->next)
>

I meaned that slab allocator maintains objects in the LIFO manner, and
if we call kmem_cache_alloc(cache) after a kmem_cache_free(cache)
call, the last object freed by kmem_cache_free(cache) will be
returned, as this object are more likely in cache and hot. If we don't
realse skbs in FIFO manner, the last and hot one will not been
returned at first.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

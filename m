From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.x, 2.6.39 sfq? kernel panic in sfq_enqueue
Date: Mon, 23 May 2011 15:23:46 +0200
Message-ID: <1306157026.20687.11.camel@edumazet-laptop>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
	 <1306153938.20687.2.camel@edumazet-laptop>
	 <1306155058.20687.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:46920 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146Ab1EWNXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 09:23:49 -0400
Received: by wwk4 with SMTP id 4so1448640wwk.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 06:23:48 -0700 (PDT)
In-Reply-To: <1306155058.20687.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 mai 2011 =C3=A0 14:50 +0200, Eric Dumazet a =C3=A9crit :

> And in your report RAX =3D R12 !!! (ffff8801172a7d08) I cant see how =
it
> can happen (Its not even a valid skb address, since an SKB should be
> 64bytes aligned)

Hmm, I wonder if it could come from sfq_peek()

Current code does :

return q->slots[q->tail->next].skblist_next;

maybe skblist_next points to itself (slot with no packets)

So I guess we should just call generic qdisc_peek_dequeued




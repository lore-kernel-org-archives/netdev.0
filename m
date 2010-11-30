From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: avoid the unnecessary kmalloc
Date: Tue, 30 Nov 2010 09:16:49 +0100
Message-ID: <1291105009.2725.48.camel@edumazet-laptop>
References: <1291077629-6339-1-git-send-email-xiaosuo@gmail.com>
	 <1291099921.2725.28.camel@edumazet-laptop>
	 <AANLkTiny5bXgEMt6dciURNnF+v1X6AnVrbJNo0S9FJP5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60404 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab0K3IRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 03:17:02 -0500
Received: by wyb28 with SMTP id 28so5395404wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 00:17:01 -0800 (PST)
In-Reply-To: <AANLkTiny5bXgEMt6dciURNnF+v1X6AnVrbJNo0S9FJP5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 15:45 +0800, Changli Gao a =C3=A9crit =
:

> I don't think it is a good idea, If it is, why not use
> ksize(skb->head) to set the tail pointer of skb when allocating a new
> skb.
>=20

Calling ksize() for all allocated skb would be overkill, since most of
them are correctly sized and dont need expand() at all.

In what situation do you notice this being expand_head() ever called ?


> If we do sth. like this, more cache lines maybe involved.
>=20

This has same number of _touched_ cache lines actually, and this is wha=
t
matters.

Actually I dont have strong feeling, this is a detail.



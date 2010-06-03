From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 03 Jun 2010 23:58:02 +0200
Message-ID: <1275602282.2533.72.camel@edumazet-laptop>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
	 <20100603130235.c372b38f.akpm@linux-foundation.org>
	 <1275599603.2533.58.camel@edumazet-laptop>
	 <20100603143915.f1b0ba2b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:46671 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755721Ab0FCV6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 17:58:08 -0400
Received: by wwb28 with SMTP id 28so451548wwb.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 14:58:06 -0700 (PDT)
In-Reply-To: <20100603143915.f1b0ba2b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 14:39 -0700, Andrew Morton a =C3=A9crit :

> Well.  The presence of this warning does serve to remind us how sucky
> e1000[e] is :(
>=20
> I'm not particularly fussed either way - I'm just wondering if you gu=
ys
> think this thing meets the noise-to-benefit test...
>=20

Well, in this particular case, I think its a genuine bug in the ipv6
code, not on the e1000[e] driver :)

It allocates "a priori" dev->mtu sized skb that are filled by maybe one
hundred bytes by caller.

With MTU=3D9000, this means order-2 allocations. In an ideal world, it
would be fine, but in practice, we know only fools can trust high order
allocations.

Since code is prepared to chain skbs, just make sure we cap allocations
to smaller units (up to 0xe80 bytes on a 64bit kernel)

So in this particular case, the bugzilla report can point to a real
problem in our stack.

=46ailed allocations had been silent, we probably would never have
noticed.

Hmm...




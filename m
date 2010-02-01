From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_key: fix netns ops ordering on module load/unload
Date: Mon, 01 Feb 2010 14:56:30 +0100
Message-ID: <1265032590.2848.40.camel@edumazet-laptop>
References: <20100129094822.GA8294@nb-core2.darkstar.lan>
	 <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
	 <1264778549.3184.28.camel@edumazet-laptop>
	 <1264782806.3184.42.camel@edumazet-laptop> <20100130125327.GA4258@x200>
	 <68676e01002010550l2654208dged864973a996c381@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:34379 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab0BAN4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 08:56:36 -0500
In-Reply-To: <68676e01002010550l2654208dged864973a996c381@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 f=C3=A9vrier 2010 =C3=A0 14:50 +0100, Luca Tettamanti a =C3=
=A9crit :
> On Sat, Jan 30, 2010 at 1:53 PM, Alexey Dobriyan <adobriyan@gmail.com=
> wrote:

> > [PATCH] af_key: fix netns ops ordering on module load/unload
> >
> > 1. After sock_register() returns, it's possible to create sockets,
> >   even if module still not initialized fully (blame generic module =
code
> >   for that!)
> > 2. Consequently, pfkey_create() can be called with pfkey_net_id sti=
ll not
> >   initialized which will BUG_ON in net_generic():
> >        kernel BUG at include/net/netns/generic.h:43!
> > 3. During netns shutdown, netns ops should be unregistered after
> >   key manager unregistered because key manager calls can be trigger=
ed
> >   from xfrm_user module:
> >
> >        general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEAL=
LOC
> >        pfkey_broadcast+0x111/0x210 [af_key]
> >        pfkey_send_notify+0x16a/0x300 [af_key]
> >        km_state_notify+0x41/0x70
> >        xfrm_flush_sa+0x75/0x90 [xfrm_user]
> > 4. Unregister netns ops after socket ops just in case and for symme=
try.
> >
> > Reported by Luca Tettamanti.
> >
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>=20
> Tested-by: Luca Tettamanti <kronos.it@gmail.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>




From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: More prefetch fall-out
Date: Sun, 22 May 2011 20:51:43 +0200
Message-ID: <1306090303.12435.35.camel@edumazet-laptop>
References: <BANLkTi=YwLaoTVjKguH-uZpZgXduLhiTNg@mail.gmail.com>
	 <1306088626.12435.27.camel@edumazet-laptop>
	 <BANLkTimQAhP17Hg6D84gtCO3nJ_SSsDAeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60749 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab1EVSvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 14:51:48 -0400
Received: by wwa36 with SMTP id 36so5527566wwa.1
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 11:51:47 -0700 (PDT)
In-Reply-To: <BANLkTimQAhP17Hg6D84gtCO3nJ_SSsDAeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 22 mai 2011 =C3=A0 11:38 -0700, Linus Torvalds a =C3=A9crit=
 :
> On Sun, May 22, 2011 at 11:23 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >
> > Taking a look at various skb_queue_walk* call sites, I think prefet=
ches
> > are not a clear win, I would just remove them all from skbuff.h
>=20
> Hmm.
>=20
> I did that, and it turns out that we also have:
>=20
>  - *lots* of network drivers that use "prefetch" (without including p=
refetch.h)
>  - net/netlabel/netlabel_addrlist.h doing the same.
>=20
> and fixing that up is annoying "grunt work".
>=20
> So for now, I think I'll just do the "add the <linux/prefetch.h> to
> <linux/skbuff.h>" thing, and leave networking alone. That makes
> everything compile ("allyesconfig") even with my "you *have* to
> include <linux/prefetch.h>" test-patch.
>=20

Or include <linux/prefetch.h> from linux/skbuff.h but remove the
prefetch() calls...

BTW this reminds me Andi Kleen prior patch

http://linux.derkeiler.com/Mailing-Lists/Kernel/2010-09/msg03096.html





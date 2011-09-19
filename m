From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix lockdep issue in __neigh_event_send
Date: Mon, 19 Sep 2011 23:03:27 +0200
Message-ID: <1316466207.2455.15.camel@edumazet-laptop>
References: <1316459578-23413-1-git-send-email-zenczykowski@gmail.com>
	 <1316461375.2455.4.camel@edumazet-laptop>
	 <CANP3RGdxYg0Utfyrqfwoj+ojfCD+ZYJTa91nzPSdWBznZWKHaA@mail.gmail.com>
	 <1316465182.2455.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	MuraliRaja Muniraju <muralira@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:59644 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863Ab1ISVDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 17:03:34 -0400
Received: by wwn22 with SMTP id 22so4501946wwn.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 14:03:32 -0700 (PDT)
In-Reply-To: <1316465182.2455.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 22:46 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le lundi 19 septembre 2011 =C3=A0 13:39 -0700, Maciej =C5=BBenczykows=
ki a =C3=A9crit :
> > [   90.544012] the existing dependency chain (in reverse order) is:
> > [   90.544012]
> > [   90.544012] -> #2 (&(&rt_hash_locks[i])->rlock){+.-...}:
> > [   90.544012]        [<ffffffff810a4910>] __lock_acquire+0xb3b/0xc=
da
> > [   90.544012]        [<ffffffff810a4b72>] lock_acquire+0xc3/0xe9
> > [   90.544012]        [<ffffffff81430d66>] _raw_spin_lock_bh+0x36/0=
x45
> > [   90.544012]        [<ffffffff813d9659>] rt_dst_release+0x4a/0x8d

rt_dst_release() again...

> > [   90.544012]        [<ffffffff813bee34>] dst_release+0x5d/0x66
> > [   90.544012]        [<ffffffff813af24e>] skb_release_head_state+0=
x1f/0xa5
> > [   90.544012]        [<ffffffff813aefec>] __kfree_skb+0x16/0x87
> > [   90.544012]        [<ffffffff813af101>] kfree_skb+0x72/0x7a
> > [   90.544012]        [<ffffffff813c06f9>] __neigh_event_send+0x126=
/0x176
> >=20

> Hmm
>=20
> What exact kernel version is it ?
>=20
>=20

Just to say what I already said to Murali raja Muniraju one week ago :

To my knowledge, no linux pristine linux kernel has this bug.

dst_release() is lockless.

So could you explain why its so important we add this 'bugfix' if it
only applies to a Google kernel ?

Anything I missed from my previous analysis ?

Thanks !

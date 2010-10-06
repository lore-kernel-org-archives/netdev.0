From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Wed, 06 Oct 2010 05:28:49 +0200
Message-ID: <1286335729.4861.13.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
	 <1286289703.2796.292.camel@edumazet-laptop>
	 <1286290393.7071.38.camel@firesoul.comx.local>
	 <1286291947.2796.387.camel@edumazet-laptop>
	 <1286312479.2593.35.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	 <AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56107 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980Ab0JFD2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:28:53 -0400
Received: by wyb28 with SMTP id 28so6781842wyb.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 20:28:52 -0700 (PDT)
In-Reply-To: <AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 octobre 2010 =C3=A0 15:34 -0700, Jeff Kirsher a =C3=A9crit =
:
> On Tue, Oct 5, 2010 at 14:16, Jesper Dangaard Brouer <hawk@diku.dk> w=
rote:
> > On Tue, 5 Oct 2010, Eric Dumazet wrote:
> >
> >> Le mardi 05 octobre 2010 =C3=A0 17:19 +0200, Eric Dumazet a =C3=A9=
crit :
> >>>
> >>> Le mardi 05 octobre 2010 =C3=A0 16:53 +0200, Jesper Dangaard Brou=
er a =C3=A9crit :
> >>>
> >>>> Its already racy, because "ethtool -S" reads out the stats immed=
iately,
> >>>> and thus races with the timer.
> >>>>
> >>>> See: igb_ethtool.c
> >>>>  igb_get_ethtool_stats() invoke igb_update_stats(adapter);
> >>>>
> >>>
> >>> You would be surprised how many bugs are waiting to be found and
> >>> fixed ;)
> >>
> >> I took a look at igb stats, and it appears they also are racy on 3=
2bit
> >> arches. igb uses u64 counters, with no synchronization between
> >> producers(writers) and consumers(readers).
> >
> > Are you saying, that we need more than a simple mutex in igb_update=
_stats()?
> >
> >
> >> Some fixes are needed ;)
> >
> > The question is then if Intel wants to fix it, or let it be up to y=
ou or me?
> >
>=20
> I will make sure that Carolyn and Alex know about the issue.  But,
> feel free to submit a patch if you guys have the time.
>=20

I woke up early this morning, I'll provide patches to fix issues for
net-next-2.6

I'll let Intel guys doing the backporting work, but for old kernels,
you'll probably need to use "unsigned long" instead of "u64"

My plan is :

- Provide 64bit counters even on 32bit arch
- with proper synchro (include/linux/u64_stats_sync.h)
- Add a spinlock so we can apply Jesper patch.




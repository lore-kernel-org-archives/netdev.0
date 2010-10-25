From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 22:38:26 +0200
Message-ID: <1288039106.3296.4.camel@edumazet-laptop>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jpirko@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61167 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757573Ab0JYUif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:38:35 -0400
Received: by wwe15 with SMTP id 15so3933692wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 13:38:34 -0700 (PDT)
In-Reply-To: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 octobre 2010 =C3=A0 15:06 -0400, nhorman@tuxdriver.com a =C3=
=A9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
>=20
> It was shown to me recently that systems under high load were driven =
very deep
> into swap when tcpdump was run.  The reason this happened was because=
 the
> AF_PACKET protocol has a SET_RINGBUFFER socket option that allows the=
 user space
> application to specify how many entries an AF_PACKET socket will have=
 and how
> large each entry will be.  It seems the default setting for tcpdump i=
s to set
> the ring buffer to 32 entries of 64 Kb each, which implies 32 order 5
> allocation.  Thats difficult under good circumstances, and horrid und=
er memory
> pressure.
>=20
> I thought it would be good to make that a bit more usable.  I was goi=
ng to do a
> simple conversion of the ring buffer from contigous pages to iovecs, =
but
> unfortunately, the metadata which AF_PACKET places in these buffers c=
an easily
> span a page boundary, and given that these buffers get mapped into us=
er space,
> and the data layout doesn't easily allow for a change to padding betw=
een frames
> to avoid that, a simple iovec change is just going to break user spac=
e ABI
> consistency.
>=20
> So instead I've done this.  This patch does the aforementioned change=
,
> allocating an array of pages instead of one contiguous chunk, and the=
n vmaps the
> array into a contiguous memory space, so that it can still be accesse=
d in the
> same way it was before.  This allows for a consisten user and kernel =
space
> behavior for memory mapped AF_PACKET sockets, which at the same time =
relieving
> the memory pressure placed on a system when tcpdump defaults are used=
=2E
>=20
> Tested successfully by me.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> ---

Strange because last time I took a look at this stuff, libpcap was doin=
g
several tries, reducing page orders until it got no allocation
failures...

(It tries to get high order pages, maybe to reduce TLB pressure...)

I remember adding __GFP_NOWARN to avoid a kernel message, while tcpdump
was actually working...




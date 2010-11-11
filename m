From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v4)
Date: Thu, 11 Nov 2010 07:29:05 +0100
Message-ID: <1289456945.17691.947.camel@edumazet-laptop>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
	 <1289416194-1844-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, zenczykowski@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46085 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757356Ab0KKG3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 01:29:10 -0500
Received: by wyb28 with SMTP id 28so316971wyb.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 22:29:08 -0800 (PST)
In-Reply-To: <1289416194-1844-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 14:09 -0500, nhorman@tuxdriver.com =
a
=C3=A9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
>=20
> Version 4 of this patch.
>=20
> Change notes:
> 1) Removed extra memset.  Didn't think kcalloc added a GFP_ZERO the w=
ay kzalloc did :)
>=20
> Summary:
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
> So I've done this, I've added a three tiered mechanism to the af_pack=
et set_ring
> socket option.  It attempts to allocate memory in the following order=
:
>=20
> 1) Using __get_free_pages with GFP_NORETRY set, so as to fail quickly=
 without
> digging into swap
>=20
> 2) Using vmalloc
>=20
> 3) Using __get_free_pages with GFP_NORETRY clear, causing us to try a=
s hard as
> needed to get the memory
>=20
> The effect is that we don't disturb the system as much when we're und=
er load,
> while still being able to conduct tcpdumps effectively.
>=20
> Tested successfully by me.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Neil !



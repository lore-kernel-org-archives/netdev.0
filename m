From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Thu, 01 Dec 2011 21:20:44 +0100
Message-ID: <1322770844.2750.1.camel@edumazet-laptop>
References: <4ED7C367.3070109@profihost.ag>
	 <20111201182309.GA10686@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Priebe <s.priebe@profihost.ag>, netdev@vger.kernel.org,
	Dave Chinner <david@fromorbit.com>, stable@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56486 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab1LAUUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 15:20:50 -0500
In-Reply-To: <20111201182309.GA10686@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 13:23 -0500, Christoph Hellwig a =
=C3=A9crit :
> On Thu, Dec 01, 2011 at 07:11:51PM +0100, Stefan Priebe wrote:
> > Hi,
> >=20
> > i'm not quite sure if this is an XFS thing or a tcp thing. As the
> > stacktrace confuses me a little but as it contains
> > xfs_bmap_search_extents and xfs_iunlock. Kernel is 3.0.11 running a=
s
> > 2.6.40.11.
> >=20
> > [171464.091567] BUG: unable to handle kernel NULL pointer
> > dereference at 000000000000002c
> > [171464.092073] IP: [<ffffffff815494f6>] ipv4_dst_check+0xb6/0x190
> > [171464.092073] PGD 15344e067 PUD 14c821067 PMD 0
> > [171464.092073] Oops: 0002 [#1] SMP
> >=20
> > Full Stacktrace:
> > http://pastebin.com/raw.php?i=3DQNg6jD2t
>=20
> The ? entries mean even the backtrace code things they are unreliable=
,
> and mos of the cases I've seen they are wrong.  In this case it looks
> like the process was doing XFS work before, but the current system ca=
ll
> indeed is purely in the networking code.
>=20
> I've changed the cc list to the netdev list which is more appropinqua=
te.

Probably fixed by commit 81d54ec8479a2c695760da
(net: fix NULL dereferences in check_peer_redir())

But this patch needs some followup patches (some of them in David net
tree, not yet in Linus tree)

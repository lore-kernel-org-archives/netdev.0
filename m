From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Thu, 27 Feb 2014 10:48:19 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1402271042240.21399@pobox.suse.cz>
References: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:32990 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbaB0JsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 04:48:23 -0500
In-Reply-To: <CAJZOPZKLcFC5Wqv7VS7AyovaeHw3PYSWEz9t9sZ4AMhG+dS1+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Feb 2014, Or Gerlitz wrote:

> > But let's make sure that we don't diverge from the original problem too
> > much. Simple fact is that the deadlock is there when using connected mode,
> > and there is nothing preventing users from using it this way, therefore I
> > believe it should be fixed one way or another.
> 
> the patch is titled with "mlx4:" -- do you expect the problem to come
> into play only when ipoib connected mode runs over the mlx4 driver?
> what's about mlx5 or other upstream IB drivers?

Honestly, I have no idea. I am pretty sure that Mellanox folks have much 
better understanding of the mlx* driver internals than I do. I tried to 
figure out where mlx5 is standing in this respect, but I don't even see 
where ipoib_cm_tx->tx_ring is being allocated there.

> I'll be looking on the details of the problem/solution,

Awesome, thanks a lot, that's highly appreciated.

> Do we have a way to tell a net-device instance they should do their
> memory allocations in a NOFS manner? if not, shouldn't we come up with
> more general injection method?

I don't think we have, and it indeed should be rather easy to add. The 
more challenging part of the problem is where (and based on which data) 
the flag would actually be set up on the netdevice so that it's not 
horrible layering violation.

-- 
Jiri Kosina
SUSE Labs

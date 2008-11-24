From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gen_estimator: Fix gen_kill_estimator() lookups
Date: Mon, 24 Nov 2008 15:49:02 -0800 (PST)
Message-ID: <20081124.154902.123250582.davem@davemloft.net>
References: <20081124120404.GA16413@ff.dom.local>
	<1227532725.22481.14.camel@dogo.mojatatu.com>
	<20081124133724.GC16755@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, slavon@bigtelecom.ru, denys@visp.net.lb,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753704AbYKXXtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:49:04 -0500
In-Reply-To: <20081124133724.GC16755@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 24 Nov 2008 13:37:24 +0000

> On Mon, Nov 24, 2008 at 08:18:45AM -0500, jamal wrote:
> > On Mon, 2008-11-24 at 12:04 +0000, Jarek Poplawski wrote:
> > > gen_kill_estimator() linear lists lookups are very slow, and e.g. while
> > > deleting a large number of HTB classes soft lockups were reported. Here
> > > is another try to fix this problem: this time internally, with rbtree,
> > > so similarly to Jamal's hashing idea IIRC. (Looking for next hits could
> > > be still optimized, but it's really fast as it is.)
> > 
> > Certainly a big improvement. Compared to hashing i suggested:
> > the deletion speed is probably equal or better than using a hash.
> > I think a hash would have performed better in the case of addition
> > than the rb tree; but you primarily concerned about deletion, so this
> > good.
> 
> I first thought about a hash, but alas Patrick's solution is sched
> only... Anyway, I din't see too much overhead in memory use, and no
> diffrence in addition times (without batching).

The kinds of things that can matter in using tree vs. hash really
only occur in the data path, and all of this stuff is control plane.

> > Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied to net-next-2.6, thanks everyone.

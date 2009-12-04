From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Fri, 04 Dec 2009 02:51:38 -0800
Message-ID: <1259923898.23199.23.camel@localhost>
References: <4B17EFE3.4080301@gmail.com>
	 <20091203202937.GA11436@ami.dom.local> <4B182DC6.5030800@gmail.com>
	 <20091203.133108.254093305.davem@davemloft.net>
	 <4B1832DD.1070805@gmail.com> <20091203224742.GA16646@ami.dom.local>
	 <4B18440A.2080507@gmail.com>  <20091204074833.GA6478@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41116 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbZLDKvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 05:51:33 -0500
In-Reply-To: <20091204074833.GA6478@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-03 at 23:48 -0800, Jarek Poplawski wrote:
> On Fri, Dec 04, 2009 at 12:04:42AM +0100, Eric Dumazet wrote:
> > Jarek Poplawski a =C3=A9crit :
> > > On Thu, Dec 03, 2009 at 10:51:25PM +0100, Eric Dumazet wrote:
> > >> David Miller a =C3=A9crit :
> > >>> From: Eric Dumazet <eric.dumazet@gmail.com>
> > >>> Date: Thu, 03 Dec 2009 22:29:42 +0100
> > >>>
> > >>>> Nice patch, thanks :)
> > >>>>
> > >>>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> > >>> I like it too, but please resubmit once we have at least
> > >>> one example user submitted.
> > >>>
> > >> I successfully tested following patch.
> > >=20
> > > Great! But, I see, checking if realloc_netdev_mq() use is always =
legal
> > > (before register_netdev()) is not trivial in this driver. (I have=
 some
> > > suspicions around ixgbe_resume().) I wonder, if there should be a=
dded
> > > some debugging for this.
> >=20
> > Yes, probably
> >=20
> > Or even better, allowing realloc_netdev_mq() to be called even afte=
r
> > register_netdev() :)
>=20
> We should try to avoid it because of clashes with qdisc initializatio=
n
> (especially wrt. preserving stats). But mainly it's about knowing the
> exact reason why this thing (probing the hardware for max mq
> capabilities) can't be finished before register_netdev(). I'll try to
> look at this more.
>=20

Honestly, there's no reason we can't know how many Tx queues we'll have
prior to registering the netdev.  All of this should be figured out
after ixgbe_alloc_queues() and ixgbe_init_interrupt_scheme() are called=
=2E

Once we know what features are enabled, and how many MSI-X vectors the
platform gives us, we can make the call for how many queues to allocate=
=2E

I like this realloc_netdev_mq() mechanism.  I'm going to pull that into
my tree for testing, since I unfortunately was unaware it existed (lack
of my poking around).  This is good stuff.

Cheers,
-PJ



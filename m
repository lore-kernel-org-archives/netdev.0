From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 18:46:02 +0000
Message-ID: <1291142762.21077.47.camel@bwh-desktop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <1290705163.4274.12.camel@localhost>
	 <1291054477.3435.1302.camel@edumazet-laptop>
	 <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
	 <1291142377.2904.176.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12390 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab0K3SqG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:46:06 -0500
In-Reply-To: <1291142377.2904.176.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 19:39 +0100, Eric Dumazet wrote:
> Le mardi 30 novembre 2010 =C3=A0 10:31 -0800, Tom Herbert a =C3=A9cri=
t :
> > On Mon, Nov 29, 2010 at 10:14 AM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
> > > I was thinking of using XPS tx_queue->cpu mapping to eventually a=
llocate
> > > memory with correct NUMA affinities, for qdisc/class stuff for ex=
ample.
> > >
> >=20
> > An interesting idea, but the real question is can this be used for =
all
> > queue related allocations.  This includes those that drivers alloca=
te
> > which are probably done in initialization.
> >=20
>=20
> This would need a callback to device, to eventually re-allocate its r=
ing
> buffer (or whatever data structures it allocated). Probably worth it,
> considering size of txbd on some NICS (up to one cache line per entry=
)
>=20
> Right now, they tend to allocate their memory on a single NUMA node, =
so
> it is a problem.

Yes, that's why I proposed an ethtool interface for reconfiguring this.
Although to be honest I haven't yet constructed a case where it made a
difference.  I think the most important objects to be allocated on the
right node are RX buffers, and as long as refill is scheduled on the
same CPU as the IRQ this already happens.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


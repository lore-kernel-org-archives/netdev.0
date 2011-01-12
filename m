From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rndis gadget: Inconsistent locking
Date: Wed, 12 Jan 2011 14:32:20 +0100
Message-ID: <1294839140.3981.23.camel@edumazet-laptop>
References: <20110112122811.GA9513@ff.dom.local>
	 <1294837632.3981.18.camel@edumazet-laptop>
	 <20110112132314.GA9920@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Brownell <david-b@pacbell.net>,
	=?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>,
	Neil Jones <neiljay@gmail.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52382 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282Ab1ALNcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 08:32:25 -0500
In-Reply-To: <20110112132314.GA9920@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 janvier 2011 =C3=A0 13:23 +0000, Jarek Poplawski a =C3=A9=
crit :
> On Wed, Jan 12, 2011 at 02:07:12PM +0100, Eric Dumazet wrote:
> ...
> >=20
> > Hmm...=20
> >=20
> > So all net devices in gen_ndis_query_resp() should have a
> > ndo_get_stats() or ndo_get_stats64() method, not allowed to use
> > spin_lock_bh() / spin_unlock_bh()
> >=20
> > If yes, we should add big fat comments to pn_net_stats()/eth_get_st=
ats() so that nobody
> > tries to revert your patch ;)
>=20
> I'm not sure I got your point: my patch could be replaced with
> ndo_get_stats64() implementing irq safe locking or by changing
> gen_ndis_query_resp() calling context. It's intended as a fast
> (compatible) fix.

I was mentioning that we tried in past months to remove useless
ndo_get_stats() methods that were only doing :

return &net->stats;

random commit : b27d50a9ff5cf2775b7a4daf5

Another possibility would be to use u64_stats_sync.h for these txq
counters.

(no locking needed to read counters, only a seqcount fetch/retry)

As a bonus, no overhead on 64bit arches.



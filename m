From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ixgbe: is DCA really that good ?
Date: Wed, 06 Apr 2011 18:14:22 +0200
Message-ID: <1302106462.3209.111.camel@edumazet-laptop>
References: <1302097444.3209.85.camel@edumazet-laptop>
	 <BANLkTimSRhuVTcOX-EHx74_y3pnDdCRi8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Brattain <ross.b.brattain@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42226 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab1DFQO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 12:14:27 -0400
Received: by wwa36 with SMTP id 36so1966727wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 09:14:26 -0700 (PDT)
In-Reply-To: <BANLkTimSRhuVTcOX-EHx74_y3pnDdCRi8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 08:24 -0700, Tom Herbert a =C3=A9crit =
:
> On Wed, Apr 6, 2011 at 6:44 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Hi guys
> >
> >
> > In a forwarding [or RPS/RFS] setup, why should we populate cpu cach=
es
> > with full frames content ? We only need first cache line to perform
> > routing [or RPS/RFS] decision.
> >
> DCA + accelerated RFS might make good.  But I agree that it should be
> configurable.

An IRQ affinity mismatch is fatal with dca-core current code, because

dca3_get_tag() ->
	dca_common_get_tag() ->
		spin_lock_irqsave(&dca_lock, flags);

Wei Gu hit this on a 64 cpus machine (but only 8 cpus servicing ixgbe
interrupts), and finding the problem took lot of time.




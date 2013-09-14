From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net 0/4] bridge: Fix problems around the PVID
Date: Sun, 15 Sep 2013 00:42:18 +0900
Message-ID: <1379173338.1730.24.camel@localhost.localdomain>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
	 <20130912.160033.779509034953932316.davem@davemloft.net>
	 <1379074013.1678.16.camel@localhost.localdomain>
	 <20130913152114.GD695@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, makita.toshiaki@lab.ntt.co.jp,
	vyasevic@redhat.com, netdev@vger.kernel.org,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:41171 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3INPmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 11:42:24 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so2425181pbb.27
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 08:42:24 -0700 (PDT)
In-Reply-To: <20130913152114.GD695@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-13 at 17:21 +0200, Veaceslav Falico wrote:
> On Fri, Sep 13, 2013 at 09:06:53PM +0900, Toshiaki Makita wrote:
> >On Thu, 2013-09-12 at 16:00 -0400, David Miller wrote:
> >> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> >> Date: Tue, 10 Sep 2013 19:27:54 +0900
> >>
> >> > There seem to be some undesirable behaviors related with PVID.
> >> > 1. It has no effect assigning PVID to a port. PVID cannot be applied
> >> > to any frame regardless of whether we set it or not.
> >> > 2. FDB entries learned via frames applied PVID are registered with
> >> > VID 0 rather than VID value of PVID.
> >> > 3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
> >> > This leads interoperational problems such as sending frames with VID
> >> > 4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
> >> > 0 as they belong to VLAN 0, which is expected to be handled as they have
> >> > no VID according to IEEE 802.1Q.
> >> >
> >> > Note: 2nd and 3rd problems are potential and not exposed unless 1st problem
> >> > is fixed, because we cannot activate PVID due to it.
> >>
> >> Please work out the issues in patch #2 with Vlad and resubmit this
> >> series.
> >>
> >> Thank you.
> >
> >I'm hovering between whether we should fix the issue by changing vlan 0
> >interface behavior in 8021q module or enabling a bridge port to sending
> >priority-tagged frames, or another better way.
> 
> Take a look at how was it done for bonding - it just goes through the list
> of attached vlan devs, and doesn't care about vlan0 (which can, btw, exist
> technically). I'm not sure if that's what you're looking for, but worth a
> try.
> 
> bond_arp_send_all() might be a good starting point.

Thanks a lot.
I looked over it and took it that bonding driver doesn't send any arp
probe as a priority-tagged frame even if the routing table tells that
the outgoing interface to reach the arp target is bond0.0.

If we seek to take a similar way with bonding, we might be able to
simply ignore vlan 0 interface, or incoming priority-tagged frames.
I'm, however, afraid that it may be undesirable in view of
interoperability.

Anyway, thank you again for your suggestion.
I'm going to think a bit more about the issue and rearrange the patch
set.

Thanks,

Toshiaki Makita

> 
> >
> >If you could comment it, I'd appreciate it :)
> >
> >
> >BTW, I think what is discussed in patch #2 is another problem about
> >handling priority-tags, and it exists without this patch set applied.
> >It looks like that we should prepare another patch set than this to fix
> >that problem.
> >
> >Should I include patches that fix the priority-tags problem in this
> >patch set and resubmit them all together?
> >
> >
> >Thanks,
> >
> >Toshiaki Makita
> >
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html

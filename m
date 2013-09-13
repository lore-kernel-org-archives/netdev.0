From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net 0/4] bridge: Fix problems around the PVID
Date: Fri, 13 Sep 2013 21:06:53 +0900
Message-ID: <1379074013.1678.16.camel@localhost.localdomain>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
	 <20130912.160033.779509034953932316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: makita.toshiaki@lab.ntt.co.jp, vyasevic@redhat.com,
	netdev@vger.kernel.org,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:33480 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab3IMMG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 08:06:58 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so1152472pbc.4
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 05:06:57 -0700 (PDT)
In-Reply-To: <20130912.160033.779509034953932316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 16:00 -0400, David Miller wrote:
> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Date: Tue, 10 Sep 2013 19:27:54 +0900
> 
> > There seem to be some undesirable behaviors related with PVID.
> > 1. It has no effect assigning PVID to a port. PVID cannot be applied
> > to any frame regardless of whether we set it or not.
> > 2. FDB entries learned via frames applied PVID are registered with
> > VID 0 rather than VID value of PVID.
> > 3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
> > This leads interoperational problems such as sending frames with VID
> > 4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
> > 0 as they belong to VLAN 0, which is expected to be handled as they have
> > no VID according to IEEE 802.1Q.
> > 
> > Note: 2nd and 3rd problems are potential and not exposed unless 1st problem
> > is fixed, because we cannot activate PVID due to it.
> 
> Please work out the issues in patch #2 with Vlad and resubmit this
> series.
> 
> Thank you.

I'm hovering between whether we should fix the issue by changing vlan 0
interface behavior in 8021q module or enabling a bridge port to sending
priority-tagged frames, or another better way.

If you could comment it, I'd appreciate it :)


BTW, I think what is discussed in patch #2 is another problem about
handling priority-tags, and it exists without this patch set applied.
It looks like that we should prepare another patch set than this to fix
that problem.

Should I include patches that fix the priority-tags problem in this
patch set and resubmit them all together?


Thanks,

Toshiaki Makita

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

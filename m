From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len
 space
Date: Tue, 01 Aug 2006 17:48:18 -0700 (PDT)
Message-ID: <20060801.174818.15265745.davem@davemloft.net>
References: <m3fygjkpwb.fsf@defiant.localdomain>
	<20060801202503.GA30889@ms2.inr.ac.ru>
	<m33bcgc6jm.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40630
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750859AbWHBAsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:48:18 -0400
To: khc@pm.waw.pl
In-Reply-To: <m33bcgc6jm.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Wed, 02 Aug 2006 02:42:05 +0200

> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:
> 
> > Actually, it is historical hole in design, inherited from ancient
> > times. Calling conventions of dev->hard_header() just did not allow
> > to reallocate. BTW in 2.6 it can, if it uses pskb_expand_head().
> 
> Does that mean that hard_header() and then hard_start_xmit()
> can use pskb_expand_head() instead of skb_realloc_headroom()
> without restrictions?

It is definitely the case that ->hard_start_xmit() can use
pskb_expand_head(), some ethernet drivers even use it when they need
to clobber the IP and TCP headers to implement TSO and another entity
has a reference to the packet headers.  Just be sure to pass
GFP_ATOMIC to it in such a context.

One example is drivers/net/tg3.c:tg3_start_xmit().

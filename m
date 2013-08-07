From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: skbs delivered to 'wrong' packet_type handler
Date: Wed, 7 Aug 2013 17:57:46 +0200
Message-ID: <20130807155746.GA16408@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <20130807130856.GI3165@eerihug-hybrid.rnd.ki.sw.ericsson.se>
 <1375883743.4004.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:48906 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab3HGP5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 11:57:48 -0400
Content-Disposition: inline
In-Reply-To: <1375883743.4004.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 07, 2013 at 06:55:43AM -0700, Eric Dumazet wrote:
> Its not ignored, quite the contrary if you look at the code :
> 
> vi +3595 net/core/dev.c
> 
>         type = skb->protocol;
>         list_for_each_entry_rcu(ptype,
>                         &ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>                 if (ptype->type == type &&
>                     (ptype->dev == null_or_dev || ptype->dev == skb->dev ||
>                      ptype->dev == orig_dev)) {
>                         if (pt_prev)
>                                 ret = deliver_skb(skb, pt_prev, orig_dev);
>                         pt_prev = ptype;
>                 }
>         }
> 
> 
> pkt->dev being set is only meaningful for packet sockets.
> 
> Protocols themselves should not care. If they want to care, they must
> add their own checks.
> 
> Socket API has SO_BINDTODEVICE for this purpose.
> IP layer has RP filtering.
> 
> A protocol should register a single ptype with NULL dev.
>

Very well, we'll have to fix the protocol registration and add appropriate 
checks in TIPC then.
But i fail to understand why a handler registered on the native device needs 
to get the packets destined to a child vlan device (the ptype->dev == orig_dev 
check).

//E

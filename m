From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Sun, 26 Sep 2010 18:25:48 -0700 (PDT)
Message-ID: <20100926.182548.179922569.davem@davemloft.net>
References: <20100924063623.GA6359@ff.dom.local>
	<1285311660.2380.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, xiaosuo@gmail.com, socketcan@hartkopp.net,
	mst@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56465
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754544Ab0I0BZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:25:28 -0400
In-Reply-To: <1285311660.2380.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Sep 2010 09:01:00 +0200

> af_packet (tx with mmap) is broken. I wonder who really uses it ?

I suspect now that af_packet supports VNET headers on transmit,
there are some things using this tx+mmap thing for sure.

> To properly cope with paged skbs, it should not try to fit several
> packets per page.
> 
> The mmap api should change so that one mmaped page belongs to at most
> one skb, or else we need invasive changes in net/core
> 
> This probably makes this stuff less interesting, unless the need is to
> send big packets. In this case, why splice was not used instead of
> custom mmap ?

I don't really see what the big issue is.

When the data destructor runs it means that packet's part of the pages
are available for reuse for the tx mmap client.  And if I read it
correctly, that's exactly what tpacket_destruct_skb() is in fact doing.

There seems to be no conflict with that rule and reusing a page for
multiple packets.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 05:47:36 -0700 (PDT)
Message-ID: <20100602.054736.215546689.davem@davemloft.net>
References: <1275395667.3587.38.camel@bigi>
	<AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	<1275481219.14363.6.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932355Ab0FBMr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:47:26 -0400
In-Reply-To: <1275481219.14363.6.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 02 Jun 2010 08:20:19 -0400

> I am suprised we never caught this all this years and wondering why
> this never crashed in your example?

Well for one thing there is all sorts of "stuff" past the end of the
valid skb->data area.  For example, there is some padding and then
there is skb_shared_info().

Furthermore, the kernel allocator can round up the size it uses for
SLAB objects which gives even more padding past the end of even
skb_shared_info().

Futrhermore, the chance of the page past the page skb->data is in
being invalid is very low.  You'd have to have invalid memory in the
page after the skb->data.

All of this conspires to just letting blind reads work in a large
number of illegal cases.

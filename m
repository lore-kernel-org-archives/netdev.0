From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
 length for qdiscs
Date: Fri, 25 Jul 2008 05:16:06 -0700 (PDT)
Message-ID: <20080725.051606.107605277.davem@davemloft.net>
References: <20080725115355.GD10399@ff.dom.local>
	<20080725.045215.10253476.davem@davemloft.net>
	<20080725120849.GA25369@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752471AbYGYMQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:16:06 -0400
In-Reply-To: <20080725120849.GA25369@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 25 Jul 2008 12:08:49 +0000

> On Fri, Jul 25, 2008 at 04:52:15AM -0700, David Miller wrote:
> > What TCP depends upon is that DROP means DROP, and that the
> > packet never reached the device and has been freed.
> 
> IMHO, TCP should depend on it's skb "refcount". A qdisc, after
> passing skb to other qdisc shouldn't depend on TCP's "refcount"
> because not everything has to work like TCP.

I think it is reasonable for TCP to expect lower layers to
not return garbage.

We have cases like this all over the stack, where some code gives some
specific return value, which means "the packet was freed and not
further processed."

There is no difference for this case.

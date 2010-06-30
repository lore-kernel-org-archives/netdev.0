From: David Miller <davem@davemloft.net>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Wed, 30 Jun 2010 13:22:20 -0700 (PDT)
Message-ID: <20100630.132220.129754921.davem@davemloft.net>
References: <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
	<1277719251.4235.306.camel@edumazet-laptop>
	<AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, erblichs@earthlink.net,
	netdev@vger.kernel.org
To: james.dutton@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45758
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752232Ab0F3UWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:22:10 -0400
In-Reply-To: <AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Courtier-Dutton <james.dutton@gmail.com>
Date: Mon, 28 Jun 2010 11:17:59 +0100

> Interesting, which hardware, apart from the b44, is it that "requires"
> a hardware reset after a RX FIFO overflow.

This problem is quite common, actually.

Even though it shouldn't be, this is seemingly one of the least tested
paths of a networking chip.

You'd think the recovery would be easy, flush the fifos and drop the
packet, then rewind the RX descriptor pointer.

But it's not and I've seen everything from RX descriptor corruption
to random DMA splats elsewhere corrupting memory entirely, as a result
of a networking card taking a RX fifo overflow.

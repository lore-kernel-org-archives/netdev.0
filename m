From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Sun, 10 Jul 2011 23:54:58 -0700 (PDT)
Message-ID: <20110710.235458.1549578255936886669.davem@davemloft.net>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757003Ab1GKG4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 02:56:13 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)

>   1. under packet storm and memory pressure NIC keeps generating inte=
rrupts
>      (if non-NAPI) and indicating new buffers because it always has f=
ree
>      RX buffers --- this only wastes CPU and bus bandwidth transferri=
ng
>      data that is going to be immediately discarded;

Actually, this is exactly how I, and others advise people to implement
drivers.  It is the right thing to do.

The worst thing that can happen is to let the RX ring empty of
buffers.  Some cards hang as a result of this, and also it causes head
of line blocking on multiqueue cards, etc.

So the first thing the driver should do is try to allocate a
replacement buffer.

And if that fails, it should give the RX packet right back to the
card, and not pass it up the stack.

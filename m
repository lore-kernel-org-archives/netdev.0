From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Wed, 21 Dec 2011 14:28:41 -0500 (EST)
Message-ID: <20111221.142841.2253787084484360430.davem@davemloft.net>
References: <1324470605.2728.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324475280.7877.33.camel@zakaz.uk.xensource.com>
	<1324476138.2728.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab1LUT2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:28:49 -0500
In-Reply-To: <1324476138.2728.65.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 15:02:18 +0100

> No idea on this +2 point.

I think I know, and I believe I instructed Alexey Kuznetsov to do
this.

When sendfile() is performed, we might start the SKB with the last few
bytes of one page, and end the SKB with the first few bytes of another
page.

In order to fit a full 64K frame into an SKB in this situation we have
to accomodate this case.

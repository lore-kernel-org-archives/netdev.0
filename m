From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/3] myri10ge Large Receive Offload
Date: Thu, 28 Sep 2006 01:12:01 +0200
Message-ID: <451B0541.1030208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:3060 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1031229AbWI0XMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:12:25 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a complete rework of the myri10ge receive path. The first
patch converts skb allocation to use physical pages. The second one
adds a software implementation of Large Receive Offload. The third
one updates the driver version to 1.1.0.

The complete driver code in our CVS actually also supports high-order
allocations instead of single physical pages since it significantly
increase the performance. Order=2 allows us to receive standard frames
at line rate even on low-end hardware such as an AMD Athlon(tm) 64 X2
Dual Core Processor 3800+ (2.0GHz). Some customer might not care a lot
about memory fragmentation if the performance is better.

But, since high-order allocations are generally considered a bad idea,
we do not include the relevant code in the following patch for inclusion
in Linux. Here, we simply pass order=0 to all page allocation routines.
If necessary, I could drop the remaining reference to high-order
(especially replace alloc_pages() with alloc_page()) but I'd rather
keep it as is.

If high-order allocations are ever considered OK under some circum-
stances, we could send an additional patch (a module parameter would
be used to switch from single physical pages to high-order pages).

Thanks,
Brice


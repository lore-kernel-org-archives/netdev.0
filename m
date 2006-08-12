From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/4] VM deadlock prevention -v4
Date: Sat, 12 Aug 2006 16:14:15 +0200
Message-ID: <20060812141415.30842.78695.sendpatchset@lappy>
Cc: Indan Zupancic <indan@nul.nu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:28083 "EHLO
	amsfep20-int.chello.nl") by vger.kernel.org with ESMTP
	id S932517AbWHLOPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 10:15:04 -0400
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

here the latest effort, it includes a whole new trivial allocator with a
horrid name and an almost full rewrite of the deadlock prevention core.
This version does not do anything per device and hence does not depend 
on the new netdev_alloc_skb() API.

The reason to add a second allocator to the receive side is twofold:
1) it allows easy detection of the memory pressure / OOM situation;
2) it allows the receive path to be unbounded and go at full speed when
   resources permit.

The choice of using the global memalloc reserve as a mempool makes that
the new allocator has to release pages as soon as possible; if we were
to hoard pages in the allocator the memalloc reserve would not get 
replenished readily.

Peter

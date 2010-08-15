From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Sat, 14 Aug 2010 22:09:45 -0700 (PDT)
Message-ID: <20100814.220945.232761341.davem@davemloft.net>
References: <20100812.161050.246523792.davem@davemloft.net>
	<AANLkTinGy+-ELbVx_2WJ1wOJCsz4Rez26Q2Baisws9+C@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820Ab0HOFJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 01:09:28 -0400
In-Reply-To: <AANLkTinGy+-ELbVx_2WJ1wOJCsz4Rez26Q2Baisws9+C@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 14 Aug 2010 11:05:54 -0700

> Anyway, the lock warning I do get seems to be networking-related, and
> is appended. Does this ring any bells? It could easily be something
> old: I turn on lock debugging only when I look for bugs (or when
> people point out bugs that I've created :^/ )

This is a false positive but I have no idea how we can annotate
this to not trigger in lockdep.

These are per-cpu locks for counter management.

The get_counters() code knows that the locks for other cpu's counters
can only be taken in software interrupt context of that other cpu.  So
it is legal to turn software interrupts back on when grabbing their
locks in base context.

CC:'ing Eric Dumazet since he put the code the way it is now :-)
Via commit 24b36f0193467fa727b85b4c004016a8dae999b9
("netfilter: {ip,ip6,arp}_tables: dont block bottom half more than necessary")

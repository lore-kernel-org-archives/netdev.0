From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 20:08:46 -0700 (PDT)
Message-ID: <20120726.200846.66786272076299783.davem@davemloft.net>
References: <CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
	<20120726.155327.947597248143903676.davem@davemloft.net>
	<CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410Ab2G0DIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 23:08:49 -0400
In-Reply-To: <CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 26 Jul 2012 19:14:55 -0700

> Any idea why these look-ups are so expensive in the first place?  When
> I dump fib_trie it doesn't look like I have much there.  I would have
> thought the table would be pretty static with just 8 flows all going
> to the same destination address, but it seems like I was getting hit
> with cache misses for some reason.

A lot of the overhead comes from write traffic that results from
filling in the "fib_result" structure onto the callers stack.

The return value from a fib_lookup() has far too many components.  But
simplifying things is not easy.

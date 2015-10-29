From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] ipv6: protect mtu calculation of wrap-around
 and infinite loop by rounding issues
Date: Thu, 29 Oct 2015 07:03:11 -0700 (PDT)
Message-ID: <20151029.070311.2268753886894108048.davem@davemloft.net>
References: <1446034864-14022-1-git-send-email-hannes@stressinduktion.org>
	<1446034864-14022-2-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	dvyukov@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbbJ2Nq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:46:27 -0400
In-Reply-To: <1446034864-14022-2-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 28 Oct 2015 13:21:04 +0100

> Raw sockets with hdrincl enabled can insert ipv6 extension headers
> right into the data stream. In case we need to fragment those packets,
> we reparse the options header to find the place where we can insert
> the fragment header. If the extension headers exceed the link's MTU we
> actually cannot make progress in such a case.
> 
> Instead of ending up in broken arithmetic or rounding towards 0 and
> entering an endless loop in ip6_fragment, just prevent those cases by
> aborting early and signal -EMSGSIZE to user space.
> 
> This is the second version of the patch which doesn't use the
> overflow_usub function, which got reverted for now.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.

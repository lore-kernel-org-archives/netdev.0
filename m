From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/12] use a dynamic pool of sk_buffs to keep up with
 fast targets
Date: Mon, 02 Jul 2007 21:40:36 -0700 (PDT)
Message-ID: <20070702.214036.42772583.davem@davemloft.net>
References: <1d8423c28c48a6d26516cdc707dbcdf015a4e347.1182883861.git.ecashin@coraid.com>
	<bca4cec8ad679e8f8549cb78e012e54bfad1027e.1182883861.git.ecashin@coraid.com>
	<20070702213636.9ca1d842.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecashin@coraid.com, linux-kernel@vger.kernel.org, greg@kroah.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751062AbXGCEkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 00:40:17 -0400
In-Reply-To: <20070702213636.9ca1d842.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 2 Jul 2007 21:36:36 -0700

> My initial thought is that if there is a legitimate need for this
> new capability then it should be made available to other parts of
> the kernel rather than being private to the AEO driver.

Absolutely.

We even used to have something like this on a per-cpu basis but using
generic SLAB is so much better for caching and NUMA that we got rid of
that.

Every sk_buff private "quicklist" pool implementation you
see should essentially be NAK'd from the get go, it's
meaningless and if it's really needed one should investigate
why SKB allocations become such a problem instead of papering
over the issue. :-)

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yellowfin: Fix buffer underrun after dev_alloc_skb()
 failure
Date: Wed, 12 Aug 2009 21:08:45 -0700 (PDT)
Message-ID: <20090812.210845.84504668.davem@davemloft.net>
References: <4A7C6B08.1040800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750729AbZHMEIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:08:35 -0400
In-Reply-To: <4A7C6B08.1040800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 07 Aug 2009 19:57:28 +0200

> When dev_alloc_skb fails in the first iteration, a buffer underrun occurs.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Is this the best way to fix this? Untested, please review.

I think this is a case where this code is going to need to
be majorly reworked so that you can pass error status up
to the caller when this allocation failure happens, and
the caller can properly act upon it.

Just silently returning when no RX ring has been allocated,
and the TX ring hasn't been setup at all, is going to be
worse than the array overrun you're supposedly fixing.

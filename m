From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Sat, 20 Sep 2008 03:35:45 -0700 (PDT)
Message-ID: <20080920.033545.171821293.davem@davemloft.net>
References: <20080919.234832.127229997.davem@davemloft.net>
	<20080920004608.a3123052.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbYITKf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 06:35:58 -0400
In-Reply-To: <20080920004608.a3123052.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 20 Sep 2008 00:46:08 -0700

> Seems from the above `>> 16' you're stuffing the softirq ID into the
> upper 16 bits of call_single_data.flags.  Is it needed?  Another u32
> can be added to call_single_data for free on 64-bit, or it could be
> split into two u16's.

call_single_data is already too large, simply adding it to
struct sk_buff had negative performance impacts that are
forcing me to trim the size of the existing structure a bit.

I think just documenting the usage of the bits is better, and
I'll do that in my next rev.

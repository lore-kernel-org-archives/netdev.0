From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: consolidate netif_needs_gso() checks
Date: Fri, 08 Jan 2010 01:00:49 -0800 (PST)
Message-ID: <20100108.010049.218930041.davem@davemloft.net>
References: <20100104102153.11639.48828.stgit@localhost.localdomain>
	<20100106.203423.58447620.davem@davemloft.net>
	<20100107050721.GA2282@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751367Ab0AHJAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 04:00:40 -0500
In-Reply-To: <20100107050721.GA2282@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 7 Jan 2010 16:07:21 +1100

> On Wed, Jan 06, 2010 at 08:34:23PM -0800, David Miller wrote:
>> From: John Fastabend <john.r.fastabend@intel.com>
>> Date: Mon, 04 Jan 2010 10:21:53 +0000
>> 
>> > netif_needs_gso() is checked twice in the TX path once,
>> > before submitting the skb to the qdisc and once after
>> > it is dequeued from the qdisc just before calling
>> > ndo_hard_start().  This opens a window for a user to
>> > change the gso/tso or tx checksum settings that can
>> > cause netif_needs_gso to be true in one check and false
>> > in the other.
>> > 
>> > Specifically, changing TX checksum setting may cause
>> > the warning in skb_gso_segment() to be triggered if
>> > the checksum is calculated earlier.
>> > 
>> > This consolidates the netif_needs_gso() calls so that
>> > the stack only checks if gso is needed after the skb
>> > is dequeued from the qdisc.  Or if the device has no
>> > queue then before dev_hard_start_xmit() in dev_queue_xmit().
>> > 
>> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> 
>> Herbert, please review.
> 
> Looks fine to me.  I have just one suggestion.  The queueless
> case also calls dev_hard_start_xmit so we should be able to
> remove the existing !need_gso code from dev_queue_xmit completely.

John, please make these changes.

Thanks.

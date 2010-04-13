From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_dst_cache RCUification
Date: Tue, 13 Apr 2010 16:11:53 -0700 (PDT)
Message-ID: <20100413.161153.135265420.davem@davemloft.net>
References: <1270803809.2623.69.camel@edumazet-laptop>
	<20100413.015232.67916764.davem@davemloft.net>
	<1271199845.16881.586.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752215Ab0DMXLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 19:11:50 -0400
In-Reply-To: <1271199845.16881.586.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Apr 2010 01:04:05 +0200

> Instead of using rcu on whole "struct socket", my plan is to use a small
> structure :
> 
> struct wait_queue_head_rcu {
> 	wait_queue_head_t wait;
> 	struct rcu_head	  rcu;
> } ____cacheline_aligned_in_smp;
> 
> and make sk->sk_sleep points to this 'wait' field.

So you're relying upon the fact that in the non-FASYNC case
the struct socket's wait queue is never actually used?

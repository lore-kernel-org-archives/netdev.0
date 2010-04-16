From: Andi Kleen <andi@halobates.de>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 13:57:18 +0200
Message-ID: <87r5mf8va9.fsf@basil.nowhere.org>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37261 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123Ab0DPL5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 07:57:20 -0400
In-Reply-To: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com> (Tom Herbert's message of "Thu, 15 Apr 2010 22:47:08 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> writes:
> +
> +		/*
> +		 * If the desired CPU (where last recvmsg was done) is
> +		 * different from current CPU (one in the rx-queue flow
> +		 * table entry), switch if one of the following holds:
> +		 *   - Current CPU is unset (equal to RPS_NO_CPU).
> +		 *   - Current CPU is offline.
> +		 *   - The current CPU's queue tail has advanced beyond the
> +		 *     last packet that was enqueued using this table entry.
> +		 *     This guarantees that all previous packets for the flow
> +		 *     have been dequeued, thus preserving in order delivery.
> +		 */
> +		if (unlikely(tcpu != next_cpu) &&
> +		    (tcpu == RPS_NO_CPU || !cpu_online(tcpu) ||
> +		     ((int)(per_cpu(softnet_data, tcpu).input_queue_head -

One thing I've been wondering while reading if this should be made
socket or SMT aware.

If you're on a hyperthreaded system and sending a IPI
to your core sibling, which has a completely shared cache hierarchy,
might not be the best use of cycles.

The same could potentially true for shared L2 or shared L3 cache
(e.g. only redirect flows between different sockets)

Have you ever considered that?

This is of course something that could be addressed post-merge, not
a blocker.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

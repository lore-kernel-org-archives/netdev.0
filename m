From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: make macro tipc_wait_for_cond() smp safe
Date: Thu, 11 May 2017 22:20:06 -0400 (EDT)
Message-ID: <20170511.222006.1297917220396086411.davem@davemloft.net>
References: <1494527295-20646-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755736AbdELCUK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 22:20:10 -0400
In-Reply-To: <1494527295-20646-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 11 May 2017 20:28:15 +0200

> The macro tipc_wait_for_cond() is embedding the macro sk_wait_event()
> to fulfil its task. The latter, in turn, is evaluating the stated
> condition outside the socket lock context. This is problematic if
> the condition is accessing non-trivial data structures which may be
> altered by incoming interrupts, as is the case with the cong_links()
> linked list, used by socket to keep track of the current set of
> congested links. We sometimes see crashes when this list is accessed
> by a condition function at the same time as a SOCK_WAKEUP interrupt
> is removing an element from the list.
> 
> We fix this by expanding selected parts of sk_wait_event() into the
> outer macro, while ensuring that all evaluations of a given condition
> are performed under socket lock protection.
> 
> Fixes: commit 365ad353c256 ("tipc: reduce risk of user starvation
> during link congestion")
> 
> Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks Jon.

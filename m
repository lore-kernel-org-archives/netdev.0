From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: nft_counter: rework atomic dump
 and reset
Date: Sun, 11 Dec 2016 10:02:32 -0500 (EST)
Message-ID: <20161211.100232.574425287368543127.davem@davemloft.net>
References: <1481453040-2675-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, arnd@arndb.de
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752898AbcLKPCh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 10:02:37 -0500
In-Reply-To: <1481453040-2675-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 11 Dec 2016 11:43:59 +0100

> Dump and reset doesn't work unless cmpxchg64() is used both from packet
> and control plane paths. This approach is going to be slow though.
> Instead, use a percpu seqcount to fetch counters consistently, then
> subtract bytes and packets in case a reset was requested.
> 
> The cpu that running over the reset code is guaranteed to own this stats
> exclusively, we have to turn counters into signed 64bit though so stats
> update on reset don't get wrong on underflow.
> 
> This patch is based on original sketch from Eric Dumazet.
> 
> Fixes: 43da04a593d8 ("netfilter: nf_tables: atomic dump and reset for stateful objects")
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> v2: adjust stats on reset on the current cpu, turn 64bit counters into signed.
> 
> @David: Please, take this into net-next to help speed up thing, thanks!

Applied.

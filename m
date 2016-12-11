From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next] netfilter: nft_counter: rework atomic dump and reset
Date: Sun, 11 Dec 2016 16:13:49 +0100
Message-ID: <2354668.BqtCyL9KZm@wuerfel>
References: <1481453040-2675-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:52744 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753199AbcLKPOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 10:14:01 -0500
In-Reply-To: <1481453040-2675-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, December 11, 2016 11:43:59 AM CET Pablo Neira Ayuso wrote:
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
> 

Looks great, I had a similar idea that I was going to suggest the
other day, but yours is better anyway.

	Arnd

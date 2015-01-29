From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] fix stretch ACK bugs in TCP CUBIC and
 Reno
Date: Wed, 28 Jan 2015 22:22:17 -0800 (PST)
Message-ID: <20150128.222217.95436772179060210.davem@davemloft.net>
References: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbbA2GWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 01:22:20 -0500
In-Reply-To: <1422493299-22114-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 28 Jan 2015 20:01:34 -0500

> This patch series fixes the TCP CUBIC and Reno congestion control
> modules to properly handle stretch ACKs in their respective additive
> increase modes, and in the transitions from slow start to additive
> increase.
> 
> This finishes the project started by commit 9f9843a751d0a2057 ("tcp:
> properly handle stretch acks in slow start"), which fixed behavior for
> TCP congestion control when handling stretch ACKs in slow start mode.
> 
> Motivation: In the Jan 2015 netdev thread 'BW regression after "tcp:
> refine TSO autosizing"', Eyal Perry documented a regression that Eric
> Dumazet determined was caused by improper handling of TCP stretch
> ACKs.
> 
> Background: LRO, GRO, delayed ACKs, and middleboxes can cause "stretch
> ACKs" that cover more than the RFC-specified maximum of 2
> packets. These stretch ACKs can cause serious performance shortfalls
> in common congestion control algorithms, like Reno and CUBIC, which
> were designed and tuned years ago with receiver hosts that were not
> using LRO or GRO, and were instead ACKing every other packet.
> 
> Testing: at Google we have been using this approach for handling
> stretch ACKs for CUBIC datacenter and Internet traffic for several
> years, with good results.
> 
> v2:
>  * fixed return type of tcp_slow_start() to be u32 instead of int

Series applied, thanks Neal.

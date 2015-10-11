From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bpf: fix cb access in socket filter
 programs
Date: Sun, 11 Oct 2015 04:40:28 -0700 (PDT)
Message-ID: <20151011.044028.2103081904798346355.davem@davemloft.net>
References: <1444240541-4665-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, mingo@kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, daniel@iogearbox.net, keescook@chromium.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbJKLYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 07:24:38 -0400
In-Reply-To: <1444240541-4665-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed,  7 Oct 2015 10:55:41 -0700

> eBPF socket filter programs may see junk in 'u32 cb[5]' area,
> since it could have been used by protocol layers earlier.
> 
> For socket filter programs used in af_packet we need to clean
> 20 bytes of skb->cb area if it could be used by the program.
> For programs attached to TCP/UDP sockets we need to save/restore
> these 20 bytes, since it's used by protocol layers.
> 
> Remove SK_RUN_FILTER macro, since it's no longer used.
> 
> Long term we may move this bpf cb area to per-cpu scratch, but that
> requires addition of new 'per-cpu load/store' instructions,
> so not suitable as a short term fix.
> 
> Fixes: d691f9e8d440 ("bpf: allow programs to write to certain skb fields")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v1->v2:
> dropped extra conditional for clearing of cb for af_packet.
> 
> Since eBPF is root only, the impact of the bug is low and
> the fix can stay in net-next.

Applied to net-next, thanks.

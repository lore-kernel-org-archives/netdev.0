From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix 64-bit divide
Date: Mon, 27 Apr 2015 23:15:14 -0400 (EDT)
Message-ID: <20150427.231514.208514856523229950.davem@davemloft.net>
References: <1430170837-9394-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, holzheu@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbbD1DPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:15:16 -0400
In-Reply-To: <1430170837-9394-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 27 Apr 2015 14:40:37 -0700

> ALU64_DIV instruction should be dividing 64-bit by 64-bit,
> whereas do_div() does 64-bit by 32-bit divide.
> x64 and arm64 JITs correctly implement 64 by 64 unsigned divide.
> llvm BPF backend emits code assuming that ALU64_DIV does 64 by 64.
> 
> Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
> Reported-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> The bug is old and sneaked in during the very first eBPF code drop:
> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> but it's not affecting classic and shouldn't be backported further
> than commit 89aa075832b0 (which is the above Fixes tag).
> It was found by exhaustive tests being written by Michael Holzheu.

Ok, applied and queued up for v3.19 -stable and later.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, trace: make ctx access checks more robust
Date: Mon, 16 Jan 2017 14:42:29 -0500 (EST)
Message-ID: <20170116.144229.808563054074323602.davem@davemloft.net>
References: <1484440465-20491-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdAPTma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 14:42:30 -0500
In-Reply-To: <1484440465-20491-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 15 Jan 2017 01:34:25 +0100

> Make sure that ctx cannot potentially be accessed oob by asserting
> explicitly that ctx access size into pt_regs for BPF_PROG_TYPE_KPROBE
> programs must be within limits. In case some 32bit archs have pt_regs
> not being a multiple of 8, then BPF_DW access could cause such access.
> 
> BPF_PROG_TYPE_KPROBE progs don't have a ctx conversion function since
> there's no extra mapping needed. kprobe_prog_is_valid_access() didn't
> enforce sizeof(long) as the only allowed access size, since LLVM can
> generate non BPF_W/BPF_DW access to regs from time to time.
> 
> For BPF_PROG_TYPE_TRACEPOINT we don't have a ctx conversion either, so
> add a BUILD_BUG_ON() check to make sure that BPF_DW access will not be
> a similar issue in future (ctx works on event buffer as opposed to
> pt_regs there).
> 
> Fixes: 2541517c32be ("tracing, perf: Implement BPF programs attached to kprobes")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix two bugs in verification logic when
 accessing 'ctx' pointer
Date: Thu, 16 Apr 2015 14:10:15 -0400 (EDT)
Message-ID: <20150416.141015.2085337707033100619.davem@davemloft.net>
References: <1429139973-5473-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbbDPSKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:10:17 -0400
In-Reply-To: <1429139973-5473-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 15 Apr 2015 16:19:33 -0700

> 1.
> first bug is a silly mistake. It broke tracing examples and prevented
> simple bpf programs from loading.
 ...
> 2.
> second bug is more subtle.
> If malicious code is using the same dest register as source register,
> the checks designed to prevent the same instruction to be used with different
> pointer types will fail to trigger, since we were assigning src_reg_type
> when it was already overwritten by check_mem_access().
> The fix is trivial. Just move line:
> src_reg_type = regs[insn->src_reg].type;
> before check_mem_access().
> Add new 'access skb fields bad4' test to check this case.
> 
> Fixes: 9bac3d6d548e ("bpf: allow extended BPF programs access skb fields")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thank you.

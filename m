From: David Miller <davem@davemloft.net>
Subject: Re: sparc64 and ARM64 JIT bug
Date: Mon, 01 May 2017 23:19:08 -0400 (EDT)
Message-ID: <20170501.231908.1478616679170333208.davem@davemloft.net>
References: <20170501.223136.1311890506697006266.davem@davemloft.net>
        <e75404e5-c68d-6f08-afdc-e57174b88a32@fb.com>
        <20170501.230234.787989809925411599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, xi.wang@gmail.com,
        catalin.marinas@arm.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751065AbdEBDTL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:19:11 -0400
In-Reply-To: <20170501.230234.787989809925411599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 01 May 2017 23:02:34 -0400 (EDT)

> 	for (i = 0; i < prog->len; i++) {
> 		const struct bpf_insn *insn = &prog->insnsi[i];
> 		int ret;
> 
> 		ret = build_insn(insn, ctx);
> 		ctx->offset[i] = ctx->idx;
> 
> 		if (ret > 0) {
> 			i++;
> 			continue;
> 		}
> 		if (ret)
> 			return ret;
> 	}

Ok, the fix is to defer the ctx->offset[i] setting until after the
potential extra "i++" increment inside of the "if (ret > 0)" test.

This is how x86_64's JIT handles this.

I'm testing this fix on sparc64 now.

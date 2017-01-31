From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ethtool: convert large order kmalloc
 allocations to vzalloc
Date: Tue, 31 Jan 2017 13:29:18 -0500 (EST)
Message-ID: <20170131.132918.802187583667317438.davem@davemloft.net>
References: <1485829518-190263-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbdAaSfv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:35:51 -0500
In-Reply-To: <1485829518-190263-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 30 Jan 2017 18:25:18 -0800

> under memory pressure 'ethtool -S' command may warn:
 ...
> ~1160 mlx5 counters ~= order 4 allocation which is unlikely to succeed
> under memory pressure. Convert them to vzalloc() as ethtool_get_regs() does.
> Also take care of drivers without counters similar to
> commit 67ae7cf1eeda ("ethtool: Allow zero-length register dumps again")
> and reduce warn_on to warn_on_once.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> Dave, I think by 'careful about size calculations' you mean
> to take care of zero-length. Please let me know if I misunderstood.

I was talking about the transformation from "count, size" to
"count * size" when going from kcalloc() to vzalloc() which you
did properly.

Applied, thank you :)

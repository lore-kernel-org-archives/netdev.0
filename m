From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethtool: silence kmalloc warning
Date: Mon, 30 Jan 2017 15:50:06 -0500 (EST)
Message-ID: <20170130.155006.811869833463169479.davem@davemloft.net>
References: <1485652625-2881838-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752816AbdA3UvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:51:01 -0500
In-Reply-To: <1485652625-2881838-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 28 Jan 2017 17:17:05 -0800

> under memory pressure 'ethtool -S' command may warn:
> [ 2374.385195] ethtool: page allocation failure: order:4, mode:0x242c0c0
 ...
> ~1160 mlx5 counters ~= order 4 allocation which is unlikely to succeed
> under memory pressure.  Since 'get stats' command is not critical
> avoid reclaim and warning.
> Also convert to safer kmalloc_array.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Let's just fix this right, just like in ethtool_get_regs().

Just use vzalloc() unconditionally.  It is an entirely similar
situation.  But please be careful with the size calculations when
you make this adjustment.

Thank you.

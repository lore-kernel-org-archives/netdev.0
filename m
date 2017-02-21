From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Revert "tcp: tcp_probe: use
 spin_lock_bh()"
Date: Tue, 21 Feb 2017 13:26:47 -0500 (EST)
Message-ID: <20170221.132647.1720616047649729612.davem@davemloft.net>
References: <20170221142147.19154-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rnsanchez@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754817AbdBUS0t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:26:49 -0500
In-Reply-To: <20170221142147.19154-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 21 Feb 2017 06:21:47 -0800

> This reverts commit e70ac171658679ecf6bea4bbd9e9325cd6079d2b.
> 
> jtcp_rcv_established() is in fact called with hard irq being disabled.
> 
> Initial bug report from Ricardo Nabinger Sanchez [1] still needs
> to be investigated, but does not look like a TCP bug.
> 
> [1] https://www.spinics.net/lists/netdev/msg420960.html
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kernel test robot <xiaolong.ye@intel.com>
> Cc: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>

Applied.

But your analysis was quite sound, we can now invoke TCP input path
from user context, therefore this jprobe needs to use BH locking.  What
is the problem.

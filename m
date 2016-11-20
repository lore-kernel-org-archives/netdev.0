From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: fix racy SOCK_ZAPPED flag check in
 l2tp_ip{,6}_bind()
Date: Sat, 19 Nov 2016 22:10:06 -0500 (EST)
Message-ID: <20161119.221006.1392183968931512666.davem@davemloft.net>
References: <f04ad12d6f2a433d60baf5720b2f7a6d685d37c6.1479503186.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com,
        sploving1@gmail.com, andreyknvl@google.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753156AbcKTDKI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:10:08 -0500
In-Reply-To: <f04ad12d6f2a433d60baf5720b2f7a6d685d37c6.1479503186.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 18 Nov 2016 22:13:00 +0100

> Lock socket before checking the SOCK_ZAPPED flag in l2tp_ip6_bind().
> Without lock, a concurrent call could modify the socket flags between
> the sock_flag(sk, SOCK_ZAPPED) test and the lock_sock() call. This way,
> a socket could be inserted twice in l2tp_ip6_bind_table. Releasing it
> would then leave a stale pointer there, generating use-after-free
> errors when walking through the list or modifying adjacent entries.
 ...
> The same issue exists with l2tp_ip_bind() and l2tp_ip_bind_table.
> 
> Fixes: c51ce49735c1 ("l2tp: fix oops in L2TP IP sockets for connect() AF_UNSPEC case")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.

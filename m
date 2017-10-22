From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] soreuseport: fix initialization race
Date: Sun, 22 Oct 2017 02:04:26 +0100 (WEST)
Message-ID: <20171022.020426.437301151304003338.davem@davemloft.net>
References: <20171019190029.163693-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932270AbdJVBEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:04:30 -0400
In-Reply-To: <20171019190029.163693-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Thu, 19 Oct 2017 15:00:29 -0400

> From: Craig Gallek <kraig@google.com>
> 
> Syzkaller stumbled upon a way to trigger
> WARNING: CPU: 1 PID: 13881 at net/core/sock_reuseport.c:41
> reuseport_alloc+0x306/0x3b0 net/core/sock_reuseport.c:39
> 
> There are two initialization paths for the sock_reuseport structure in a
> socket: Through the udp/tcp bind paths of SO_REUSEPORT sockets or through
> SO_ATTACH_REUSEPORT_[CE]BPF before bind.  The existing implementation
> assumedthat the socket lock protected both of these paths when it actually
> only protects the SO_ATTACH_REUSEPORT path.  Syzkaller triggered this
> double allocation by running these paths concurrently.
> 
> This patch moves the check for double allocation into the reuseport_alloc
> function which is protected by a global spin lock.
> 
> Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
> Fixes: c125e80b8868 ("soreuseport: fast reuseport TCP socket selection")
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied and queued up for -stable.

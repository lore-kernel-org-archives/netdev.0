From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: repair fib6 tree in failure case
Date: Sun, 20 Aug 2017 20:07:31 -0700 (PDT)
Message-ID: <20170820.200731.997277808682483073.davem@davemloft.net>
References: <20170819001449.42844-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdHUDHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 23:07:32 -0400
In-Reply-To: <20170819001449.42844-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Fri, 18 Aug 2017 17:14:49 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In fib6_add(), it is possible that fib6_add_1() picks an intermediate
> node and sets the node's fn->leaf to NULL in order to add this new
> route. However, if fib6_add_rt2node() fails to add the new
> route for some reason, fn->leaf will be left as NULL and could
> potentially cause crash when fn->leaf is accessed in fib6_locate().
> This patch makes sure fib6_repair_tree() is called to properly repair
> fn->leaf in the above failure case.
> 
> Here is the syzkaller reported general protection fault in fib6_locate:
 ...
> Note: there is no "Fixes" tag as this seems to be a bug introduced
> very early.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.

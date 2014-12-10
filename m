From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: fix sparse warning
Date: Tue, 09 Dec 2014 21:40:18 -0800
Message-ID: <1418190018.27198.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1418182101-7992-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38894 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbaLJFk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 00:40:28 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so2096336pdb.10
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 21:40:28 -0800 (PST)
In-Reply-To: <1418182101-7992-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-10 at 11:28 +0800, Ying Xue wrote:
> This fixes the following sparse warning when using
> 
> make C=1 CF=-D__CHECK_ENDIAN__ net/ipv6/addrconf.o
> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
> net/ipv6/addrconf.c:3495:9: error: incompatible types in comparison expression (different address spaces)
> 
> To silence above spare complaint, an RCU annotation should be added
> to next pointer of hlist_node structure through hlist_next_rcu() macro
> when iterating over a hlist with hlist_for_each_entry_continue_rcu_bh().
> 
> By the way, this commit also resolves the same error appearing in
> hlist_for_each_entry_continue_rcu().

This probably should be sent to lkml and CC Paul E. McKenney

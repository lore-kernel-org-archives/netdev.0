From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: conntrack: remove uninitialized shadow
 variable
Date: Tue, 10 May 2016 01:04:18 -0400 (EDT)
Message-ID: <20160510.010418.1148844422449581387.davem@davemloft.net>
References: <1462823254-3137116-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	fw@strlen.de, daniel@iogearbox.net, sasha.levin@oracle.com,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbcEJFEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 01:04:21 -0400
In-Reply-To: <1462823254-3137116-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon,  9 May 2016 21:47:23 +0200

> A recent commit introduced an unconditional use of an uninitialized
> variable, as reported in this gcc warning:
> 
> net/netfilter/nf_conntrack_core.c: In function '__nf_conntrack_confirm':
> net/netfilter/nf_conntrack_core.c:632:33: error: 'ctinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    bytes = atomic64_read(&counter[CTINFO2DIR(ctinfo)].bytes);
>                                  ^
> net/netfilter/nf_conntrack_core.c:628:26: note: 'ctinfo' was declared here
>    enum ip_conntrack_info ctinfo;
> 
> The problem is that a local variable shadows the function parameter.
> This removes the local variable, which looks like what Pablo originally
> intended.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 71d8c47fc653 ("netfilter: conntrack: introduce clash resolution on insertion race")

Applied.

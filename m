From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV6 : Some cleanups in include/net/ipv6.h
Date: Thu, 03 May 2007 17:39:13 -0700 (PDT)
Message-ID: <20070503.173913.130238677.davem@davemloft.net>
References: <4636BB49.8050307@cosmosbay.com>
	<20070503.030903.123997453.davem@davemloft.net>
	<20070503183208.8e4c325b.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767541AbXEDAjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:39:12 -0400
In-Reply-To: <20070503183208.8e4c325b.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 3 May 2007 18:32:08 +0200

> 1) struct ip6_flowlabel : moves 'users' field to avoid two 32bits holes for 64bit arches. Shrinks by 8 bytes sizeof(struct ip6_flowlabel)
> 
> 2) ipv6_addr_cmp() and ipv6_addr_copy() dont need (void *) casts :
> Compiler might take into account natural alignement of in6_addr structs to emit better code for memcpy()/memcmp()
> Casts to (void *) force byte accesses.
> 
> 3) ipv6_addr_prefix() optimization :
> Better to clear whole struct, as compiler can emit better code for memset(addr, 0, 16) (2 stores on x86_64), and avoid some conditional branches.
> 
> # size vmlinux.after vmlinux.before
>    text    data     bss     dec     hex filename
> 5262262  647612  557432 6467306  62aeea vmlinux.after
> 5262550  647612  557432 6467594  62b00a vmlinux.before
> 
> thats 288 bytes saved.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.

From: David Miller <davem@davemloft.net>
Subject: Re: kmemleak complaints in ip6mr.c
Date: Tue, 29 Jan 2013 13:59:06 -0500 (EST)
Message-ID: <20130129.135906.1332264867631483230.davem@davemloft.net>
References: <20130129185127.GA31811@raven>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029Ab3A2S7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:59:13 -0500
In-Reply-To: <20130129185127.GA31811@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Tue, 29 Jan 2013 18:51:27 +0000

> I've discovered what may be a memory leak in ip6mr when using network
> namespaces.  Here's the kmemleak backtrace:
> 
> 
> unreferenced object 0xf0d4a180 (size 96):
>   comm "ip", pid 6735, jiffies 4294949643 (age 73.268s)
>   hex dump (first 32 bytes):
>     68 a1 d4 f0 00 02 20 00 01 00 00 00 00 00 00 00  h..... .........
>     00 00 00 00 00 00 00 00 00 00 00 00 ff 7f 00 00  ................
>   backtrace:
>     [<c159b50c>] kmemleak_alloc+0x2c/0x60
>     [<c1139c23>] __kmalloc+0x1c3/0x240
>     [<c14e2627>] fib_default_rule_add+0x27/0x70
>     [<c157f8df>] ip6mr_net_init+0x6f/0x140
>     [<c14c4129>] ops_init+0x39/0x110
>     [<c14c425f>] setup_net+0x5f/0xf0
>     [<c14c46e4>] copy_net_ns+0x74/0xf0
>     [<c105fc81>] create_new_namespaces+0xd1/0x160
>     [<c105fedf>] unshare_nsproxy_namespaces+0x5f/0xa0
>     [<c1038a94>] sys_unshare+0x114/0x280
>     [<c15b7ecd>] sysenter_do_call+0x12/0x28
>     [<ffffffff>] 0xffffffff

How is this memory unreferenced?  fib_rule_default_add() adds
the allocated object to the ops->rules_list as it's very last
action.

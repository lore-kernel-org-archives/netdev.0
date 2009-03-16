From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reorder fields of struct socket
Date: Sun, 15 Mar 2009 19:59:23 -0700 (PDT)
Message-ID: <20090315.195923.109697114.davem@davemloft.net>
References: <20090313.153851.11725991.davem@davemloft.net>
	<49BAE1F3.5020105@cosmosbay.com>
	<49BB72FA.1080401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org, bmb@athenacr.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbZCPC7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 22:59:36 -0400
In-Reply-To: <49BB72FA.1080401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 14 Mar 2009 10:03:54 +0100

> On x86_64, its rather unfortunate that "wait_queue_head_t wait"
> field of "struct socket" spans two cache lines (assuming a 64
> bytes cache line in current cpus)
> 
> offsetof(struct socket, wait)=0x30
> sizeof(wait_queue_head_t)=0x18
> 
> This might explain why Kenny Chang noticed that his multicast workload
> was performing bad with 64 bit kernels, since more cache lines ping pongs
> were involved.
> 
> This litle patch moves "wait" field next "fasync_list" so that both
> fields share a single cache line, to speedup sock_def_readable()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks a lot Eric.

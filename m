From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Mon, 17 Mar 2014 07:00:08 -0700
Message-ID: <1395064808.9668.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
	 <1395060178-11833-37-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:64765 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471AbaCQOAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 10:00:12 -0400
In-Reply-To: <1395060178-11833-37-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 13:42 +0100, Pablo Neira Ayuso wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> connlimit currently suffers from spinlock contention, example for
> 4-core system with rps enabled:

> +#define CONNLIMIT_SLOTS	256
> +#define CONNLIMIT_LOCK_SLOTS	32



32 spinlocks use 2 cache lines (assuming 4 bytes per spinlock, and 64
bytes cache lines)

So I guess this probably should be increased to have less false sharing.

Note: This can be done later, I do not want to block this patch serie at
all !

I believe this hash table of spinlocks could be global, not in each
struct xt_connlimit_data.

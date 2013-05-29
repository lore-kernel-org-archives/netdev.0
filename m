From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Tue, 28 May 2013 23:36:47 -0700 (PDT)
Message-ID: <20130528.233647.1209227470109213894.davem@davemloft.net>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab3E2Ggs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:36:48 -0400
In-Reply-To: <1369807740-12324-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 29 May 2013 14:09:00 +0800

> commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> fields of struct skbuff) converts skb->*_header to u16,
> therefore 1) we could just use 0xFFFFF instead of (__u16) ~0U
> 2) some #if NET_SKBUFF_DATA_USES_OFFSET is useless now.
> 
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Cong Wang <amwang@redhat.com>

I want to use something that will either break the build or
automatically work if the type changes again.

So something like "X = (typeof(X)) ~0U;".

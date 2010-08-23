From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: netfilter: fix a memory leak
Date: Sun, 22 Aug 2010 21:36:32 -0700 (PDT)
Message-ID: <20100822.213632.191389158.davem@davemloft.net>
References: <1282280596-18992-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751523Ab0HWEgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:36:15 -0400
In-Reply-To: <1282280596-18992-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 20 Aug 2010 13:03:16 +0800

> nf_bridge_alloc() always reset the skb->nf_bridge, so we should always
> put the old one. skb->nf_bridge->use is initialized in nf_bridge_alloc(),
> so we don't need to initialize it again.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

We just memcpy()'d 'nf_bridge' to 'tmp', that why the ->use count is
going to be something other than '1'.  It now has the ->use count that
'nf_bridge' did.

And that is why we must explicitly do atomic_set() on 'tmp'.

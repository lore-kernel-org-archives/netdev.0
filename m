From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC 00/10] socket sendmsg MSG_ZEROCOPY
Date: Thu, 20 Aug 2015 15:56:47 -0700 (PDT)
Message-ID: <20150820.155647.106500427975157613.davem@davemloft.net>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbbHTW4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 18:56:48 -0400
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 20 Aug 2015 10:36:39 -0400

> Datapath integrity does not otherwise depend on payload, with three
> exceptions: checksums, optional sk_filter/tc u32/.. and device +
> driver logic. The effect of wrong checksums is limited to the
> misbehaving process. Filters may have to be addressed by inserting a
> preventative skb_copy_ubufs(). Device drivers can be whitelisted,
> similar to scatter-gather support (NETIF_F_SG).

Consider a userland NFS implementation sending over loopback while
constantly modifying the page.  The sunrpc code could be tricked into
seeing one thing during validation of the RPC headers then doing
another after the user makes changes.

I really don't think this is completely safe as-is.

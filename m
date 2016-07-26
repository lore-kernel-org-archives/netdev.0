From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/2] Mellanox 100G mlx5 minimum inline
 header mode
Date: Tue, 26 Jul 2016 14:29:47 -0700 (PDT)
Message-ID: <20160726.142947.1063145474373793503.davem@davemloft.net>
References: <1469365960-27100-1-git-send-email-saeedm@mellanox.com>
	<20160725.175436.969233393280158279.davem@davemloft.net>
	<CAJL1qvFjWT4Bk_CdOdU7bECsh327nekVEFENmpU5vwFvNpMxLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	hadarh@mellanox.com
To: hadarh@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757950AbcGZV3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 17:29:48 -0400
In-Reply-To: <CAJL1qvFjWT4Bk_CdOdU7bECsh327nekVEFENmpU5vwFvNpMxLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Date: Tue, 26 Jul 2016 13:30:46 +0300

> In the default case eth_get_headlen() won't be called, it will happen
> only if PF administrator changes the mode from default to L4.
> 
> In L4 mode, we need to copy all the packet headers including L4, do
> you know of a better/cheaper way for doing that?

You can just look straight at the ethernet header in this context.

eth_get_headlen() is expensive and has a complete header parser.  It
is meant to be used when none of the SKB context state has been setup
yet (early RX processing before SKB is allocated, for example).

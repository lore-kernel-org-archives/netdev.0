From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: add sanity check before memory dereferencing
Date: Mon, 03 May 2010 23:11:56 -0700 (PDT)
Message-ID: <20100503.231156.69972880.davem@davemloft.net>
References: <1272944028-23410-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753971Ab0EDGLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:11:50 -0400
In-Reply-To: <1272944028-23410-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue,  4 May 2010 11:33:48 +0800

> add sanity check before memory dereferencing
> 
> Some callers of eth_type_trans() only can assure the length of the packets
> passed to it is not less than ETH_HLEN. We'd better check the packets length
> before dereferencing skb->data.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

We can deference skb->data for at least 16 bytes or so past the end
of the valid packet data area however we want.

It might give garbage values, but it will not cause a fault or any
kind.

We want to remove checks here, not add new ones Changli.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: call __skb_pull() in eth_type_trans()
Date: Mon, 03 May 2010 00:59:45 -0700 (PDT)
Message-ID: <20100503.005945.123415755.davem@davemloft.net>
References: <1272840617-17084-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932153Ab0ECH7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 03:59:39 -0400
In-Reply-To: <1272840617-17084-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon,  3 May 2010 06:50:17 +0800

> call __skb_pull() in eth_type_trans().
> 
> Since the callers of eth_type_trans() always feed it long enough packets,
> we can use __skb_pull() to save some cycles.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Although they should, assuming that some runts won't show up here and
never check for that condition at all is dangerous.

At least we should have a WARN_ON() check for skb->len < ETH_ZLEN here
or similar.

So many other things get layered into ethernet, which means adding
this length assumption without any checks is bound to lead to
unpleasant surprises for somebody.

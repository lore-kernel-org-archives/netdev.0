From: David Miller <davem@davemloft.net>
Subject: Re: SKB truesize bug
Date: Thu, 20 Nov 2008 04:03:11 -0800 (PST)
Message-ID: <20081120.040311.01043059.davem@davemloft.net>
References: <20080429120713.GA19937@gondor.apana.org.au>
	<20080429.223747.211215854.davem@davemloft.net>
	<COL107-W365F57B30278309D1E88F9B60C0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60174
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752595AbYKTMDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:03:11 -0500
In-Reply-To: <COL107-W365F57B30278309D1E88F9B60C0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya B <bkostya@hotmail.com>
Date: Thu, 20 Nov 2008 11:59:28 +0000

> Perhaps we should take a closer look on pskb_expand_head()
> 
> And add 
> 
> +skb->truesize = size + sizeof(struct sk_buff);

You can't.  If a socket is attached to the skb it's buffer
accounting will get corrupted if you modify skb->truesize.

This has been explained a thousand times on this list.

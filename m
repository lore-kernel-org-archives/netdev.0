From: David Miller <davem@davemloft.net>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 08 Apr 2010 05:11:44 -0700 (PDT)
Message-ID: <20100408.051144.183699401.davem@davemloft.net>
References: <20100408.035049.177640912.davem@davemloft.net>
	<20100408114738.GA23329@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758511Ab0DHMLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:11:43 -0400
In-Reply-To: <20100408114738.GA23329@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Apr 2010 19:47:38 +0800

> Another approach is to use skb_share.  At some point all protocols
> were designed to handle shared skbs.
> 
> If we could tap into that then it would be an obvious way to
> eliminate the clone.  To do this we'd need to audit all the
> protocols to ensure that they can still handle shared packets
> safely.

I don't even want to call down into the AF_PACKET code for
the case where the filter doesn't pass.

We have the socket pointer etc. already in dev_queue_xmit_nit(), so we
can easily do it.

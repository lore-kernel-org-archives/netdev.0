From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 14:56:15 -0800 (PST)
Message-ID: <20070205.145615.92339659.davem@davemloft.net>
References: <45C7A87A.5050200@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965014AbXBEW4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 17:56:16 -0500
In-Reply-To: <45C7A87A.5050200@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Mon, 05 Feb 2007 16:58:18 -0500

> This is especially important with TSO enabled.  Currently, it will send 
> a burst of up to 64k at the end of a connection, even when cwnd is much 
> smaller than 64k.  This patch still lets out empty FIN packets, but does 
> not apply the special case to FINs carrying data.

Good catch John.

But I think the correct test on skb->len would be to just make
sure that it is <= REAL_MSS.

What do you think about that?  This would match the original intention
of the logic in the pre-TSO days.

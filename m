From: David Miller <davem@davemloft.net>
Subject: Re: reading the tcp headers within the write queue
Date: Thu, 13 Dec 2007 11:13:27 -0800 (PST)
Message-ID: <20071213.111327.160083733.davem@davemloft.net>
References: <20071213185626.GV7409@nuim.ie>
	<20071213.110050.104716141.davem@davemloft.net>
	<20071213190859.GW7409@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gavin.McCullagh@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51276
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750982AbXLMTN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 14:13:28 -0500
In-Reply-To: <20071213190859.GW7409@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Date: Thu, 13 Dec 2007 19:08:59 +0000

> Thought that might be it. I presume there isn't any other residue of the
> tcp options elsewhere, that one could look at when the packet gets
> acknowledged?  I'm particularly interested in the timestamp.

Every time we transmit, the timestamp will be different.

We store the jiffies at transmit time in TCP_SKB_CB(skb)->when,
so you can use that.  This is the value we use to compute the
timestamp.


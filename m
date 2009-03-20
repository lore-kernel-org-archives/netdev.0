From: David Miller <davem@davemloft.net>
Subject: Re: skb's & hw buffer mgmt
Date: Thu, 19 Mar 2009 20:21:33 -0700 (PDT)
Message-ID: <20090319.202133.68433431.davem@davemloft.net>
References: <4FC8D5B7-3242-4C9E-BDD8-5026FC1C73F3@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755448AbZCTDVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 23:21:46 -0400
In-Reply-To: <4FC8D5B7-3242-4C9E-BDD8-5026FC1C73F3@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Thu, 19 Mar 2009 21:55:18 -0500

> It also seems that you don't actually give the page directly back to
> the HW buffer manager when the skb is released (possibly via a
> skb->destructor) but just allocate new pages and add these new
> buffers to the HW manager.  Is that correct?  Is there any
> particular reason to do this?

The pages are referenced by the packet, and therefore potentially by
protocol sockets for indefinite periods of time.  I have to allocate
new pages since we can't wait around forever for the socket to
release the data when it feels like it.

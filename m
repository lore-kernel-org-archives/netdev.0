From: David Miller <davem@davemloft.net>
Subject: Re: skb's & hw buffer mgmt
Date: Thu, 19 Mar 2009 20:20:40 -0700 (PDT)
Message-ID: <20090319.202040.227321807.davem@davemloft.net>
References: <4FC8D5B7-3242-4C9E-BDD8-5026FC1C73F3@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757964AbZCTDUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 23:20:53 -0400
In-Reply-To: <4FC8D5B7-3242-4C9E-BDD8-5026FC1C73F3@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Thu, 19 Mar 2009 21:55:18 -0500

> It appears that you allocate a bunch of pages, seed the HW buffer
> manager.  As you receive packets you setup the skb via
> niu_process_rx_pkt()/niu_rx_skb_append().  I'm a little confused
> about how the non-paged data in the skb itself is actually used.
> How does skb->data actually point to anything meaningful?

It's empty except for the ethernet header which is copied from
the paged data area with the lines:

	skb_reserve(skb, NET_IP_ALIGN);
	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));

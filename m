From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Mon, 03 Mar 2008 20:55:58 -0800 (PST)
Message-ID: <20080303.205558.114610030.davem@davemloft.net>
References: <47BDC848.50607@cosmosbay.com>
	<20080226.182120.183405235.davem@davemloft.net>
	<47C92F49.4070100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752226AbYCDE4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 23:56:00 -0500
In-Reply-To: <47C92F49.4070100@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 01 Mar 2008 11:26:17 +0100

> You are absolutly right. We should guard against recursion, using a new field 
> in "pcpu_lstats" (cheap access in a hot cache line as we have to update stats 
> anyway)
 ...
> [PATCH] loopback: calls netif_receive_skb() instead of netif_rx()

I'm willing to seriously entertain this change and stick it
into net-2.6.26 if you will perform a reasonable deep stack
test.

For example, create an XFS filesystem, and mount it NFS over
loopback.  Then stress it like crazy.

See if this generates stack overflows or weird crashes.

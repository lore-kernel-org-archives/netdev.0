From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [IPV4][IPV6][TCP] remove skb->dev NULL assignation in
 tcp_v[4|6]_rcv functions
Date: Thu, 07 Feb 2008 03:45:25 -0800 (PST)
Message-ID: <20080207.034525.74982838.davem@davemloft.net>
References: <47AAE8C7.9090109@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753044AbYBGLoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 06:44:55 -0500
In-Reply-To: <47AAE8C7.9090109@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 07 Feb 2008 12:17:27 +0100

> Subject: [RFC] remove skb->dev NULL assignation
> 
> I was trying to figure out why in the tcp_v4_rcv/tcp_v6_rcv function,
> the skb->dev field is set to NULL. There is certainly a good reason,
> but I was not able to find it.
> 
> Is it possible to remove this ?
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

It is illegal to reference a device outside of the netif_receive_skb()
code path without taking a reference to it.

Since we are queueing it to a socket, we have to NULL out the skb->dev
since thee packets lifetime is being expanded outside of that allowed
window.

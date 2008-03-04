From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst'
 field and avoid casts
Date: Mon, 03 Mar 2008 23:46:49 -0800 (PST)
Message-ID: <20080303.234649.109971767.davem@davemloft.net>
References: <47CCF71D.2030800@cosmosbay.com>
	<20080303.232342.221759327.davem@davemloft.net>
	<47CCFC0B.7060801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47115
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750859AbYCDHqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:46:50 -0500
In-Reply-To: <47CCFC0B.7060801@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 04 Mar 2008 08:36:43 +0100

> Yes, I had this idea, but felt that it was better in this case to have a 
> dst_hold() that refers to the above affectation.
> 
> skb->dst = &__fake_rtable.u.dst;
> dst_hold(skb->dst);
> 
> instead of
> 
> skb->rtable = &__fake_rtable;
> dst_hold(skb->dst);
> 
> Do you prefer the later ?

Wouldn't it be pleasant if you could pass
&__fake_rtable to dst_hold() directly?

Can't we do that by making it's arg an anonymous union like the thing
you're doing here?

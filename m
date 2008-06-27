From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Fixes entry of short packets
Date: Fri, 27 Jun 2008 18:58:34 +1000
Message-ID: <1214557114.8011.539.camel@pasglop>
References: <1214225705-25850-1-git-send-email-sr@denx.de>
	 <1214263257.8011.278.camel@pasglop>
	 <1946a170806262336y4aa3621at16520fc546bbe4b1@mail.gmail.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: SathyaNarayanan <sathyan@teamf1.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33312 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755111AbYF0I6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 04:58:45 -0400
In-Reply-To: <1946a170806262336y4aa3621at16520fc546bbe4b1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>         
> 
> Actually , short packets are not allowed to flow through the higher
> layers, If any of the layer tried to use the extra room available may
> hit wit crash .
> Since it is a invalid packet it has to be dropped and freed in driver.
> Actually if you see in code, the other invalid packets are also
> handelled similar.

My point is they should not. The rx skb should be kept in the ring for
further rx (ie, the data ignored and re-use the skb). A bit like we do
when we decide the packet is small enough to be copied to a new skb.

Ie. Move you test above the threshold test and recycle the skb.

We need to fix the usage of the dma operations in this driver anyway
and this will make it easier as we'll be able to avoid re-mapping an
skb we just recycle. (the current driver never unmaps which means it
can't be used with an iommu, which is a problem on some cell based
platforms).

Ben.




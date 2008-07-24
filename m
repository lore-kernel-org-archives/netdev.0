From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 14:56:00 -0700 (PDT)
Message-ID: <20080724.145600.30988015.davem@davemloft.net>
References: <200807241922.57361.opurdila@ixiacom.com>
	<20080724.132821.212118602.davem@davemloft.net>
	<200807250049.46939.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752007AbYGXVz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 17:55:59 -0400
In-Reply-To: <200807250049.46939.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri, 25 Jul 2008 00:49:46 +0300

> On Thursday 24 July 2008, David Miller wrote:
> 
> > Adding new fields to struct sk_buff that take up space is generally
> > not allowed unless the new field adds substantially to the benefit of
> > a large group of users of Linus.
> >
> > I don't think that applied here for this hw-tstamps stuff.
> 
> What about the approach proposed in the patch? Is it ok to add a pointer which 
> may resolve other future similar issues?

Traversing the list and maintaining the reference counting and sharing
issues is expensive and error prone.

This is what OpenBSD uses for their IPSEC state attached to MBUFs and
it's a nightmare.

We have a timestamp in the SKB already, why don't you simply override
it when your feature is enable and set a single flag bit that
indicates you used a HW timestamp to set that timestamp?

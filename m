From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:28:12 -0700 (PDT)
Message-ID: <20070829.152812.74548456.davem@davemloft.net>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
	<20070829.144656.104048365.davem@davemloft.net>
	<20070829151301.495f3d6e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48130
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752275AbXH2W2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:28:13 -0400
In-Reply-To: <20070829151301.495f3d6e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 29 Aug 2007 15:13:01 -0700

> There was some discussion about implementing TCP NCR (RFC4653)
> and Narasimha Reddy said he might have something that could be used.

Although this looks interesting, I'm unsure it will help these
cell folks.  Actually I can't tell for sure until Rick provides
us with some more details of the exact issue at hand.

NCR seems to deal with when the trigger loss recovery, whereas
the cell phone network folks aparently want to jack up TCP_RTO_MIN
so that hard timeout based retranmits are deferred a lot more
than normal.

And reading NCR some more, we already have something similar in the
form of Alexey's reordering detection, in fact it handles exactly the
case NCR supposedly deals with.  We do not trigger loss recovery
strictly on the 3rd duplicate ACK, and we've known about and dealt
with the reordering issue explicitly for years.


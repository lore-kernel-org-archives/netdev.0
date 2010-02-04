From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] NAPI as kobject proposal
Date: Wed, 03 Feb 2010 17:33:05 -0800 (PST)
Message-ID: <20100203.173305.196876047.davem@davemloft.net>
References: <20100129101839.36944ba5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58414
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932991Ab0BDBcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 20:32:51 -0500
In-Reply-To: <20100129101839.36944ba5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 29 Jan 2010 10:18:39 -0800

> As part of receive packet steering there is a requirement to add an
> additional parameter to this for the CPU map.

Hmmm, where did this come from?

The RPS maps are per-device.

I think I vaguely recall you "suggesting" that the RPS maps become
per-NAPI.

But, firstly, I didn't see any movement in that part of the
discussion.

And, secondly, I don't think this makes any sense at all.

Things are already overly complicated as it is.  Having the user know
what traffic goes to a particular RX queue (ie. NAPI instance) and set
the RPS map in some way specific to that RX queue is over the top.

If the issue is the case of sharing a NAPI instance between two
devices, there are a few other ways to deal with this.

One I would suggest is to simply clone the RPS map amongst the
devices sharing a NAPI instance.

I currently see NAPI kobjects is just an over-abstraction for a
perceived need rather than a real one.

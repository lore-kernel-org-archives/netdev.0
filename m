From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 13:04:48 -0700 (PDT)
Message-ID: <20110602.130448.917724318321380583.davem@davemloft.net>
References: <20110602185659.GA2749@hmsreliant.think-freely.org>
	<1307041789.2812.27.camel@bwh-desktop>
	<20110602194621.GB2749@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	fubar@us.ibm.com, andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab1FBUF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:05:57 -0400
In-Reply-To: <20110602194621.GB2749@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 2 Jun 2011 15:46:21 -0400

> Potentially, yes.  I only fixed this because I was looking at bonding and its
> queue_mapping behavior, and saw that this needed fixing.  Bridging and IP
> forwarding should also likely clear the queue mapping in the forwarding path
> somewhere to avoid selecting an output tx queue that is a function of whatever
> queue and device it arrived on during ingress.  I've not yet looked to see if
> thats already being done.

No we do not do this, intentionally.

That way the input classification and queue selection is mirrored
on the transmit side, which we absolutely want to happen.

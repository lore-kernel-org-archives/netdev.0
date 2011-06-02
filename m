From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 13:07:10 -0700 (PDT)
Message-ID: <20110602.130710.1904222486883754792.davem@davemloft.net>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab1FBUIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:08:19 -0400
In-Reply-To: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu,  2 Jun 2011 14:03:19 -0400

> The bonding driver is multiqueue enabled, in which each queue represents a slave
> to enable optional steering of output frames to given slaves against the default
> output policy.  However, it needs to reset the skb->queue_mapping prior to
> queuing to the physical device or the physical slave (if it is multiqueue) could
> wind up transmitting on an unintended tx queue (one that was reserved for
> specific traffic classes for instance)
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Since, as I mentioned, the idea when we are forwarding and bridging is that
we use the input receive classification to influence the spread on transmit,
I think things like this bonding case should remember the rxhash setting
before they override it and then restore that value right before invoking
dev_queue_xmit().

From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 2 Jun 2011 21:04:04 -0400
Message-ID: <20110603010403.GA2523@neilslaptop.think-freely.org>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com>
 <20110602.130710.1904222486883754792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39197 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776Ab1FCBEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 21:04:13 -0400
Content-Disposition: inline
In-Reply-To: <20110602.130710.1904222486883754792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2011 at 01:07:10PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu,  2 Jun 2011 14:03:19 -0400
> 
> > The bonding driver is multiqueue enabled, in which each queue represents a slave
> > to enable optional steering of output frames to given slaves against the default
> > output policy.  However, it needs to reset the skb->queue_mapping prior to
> > queuing to the physical device or the physical slave (if it is multiqueue) could
> > wind up transmitting on an unintended tx queue (one that was reserved for
> > specific traffic classes for instance)
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Since, as I mentioned, the idea when we are forwarding and bridging is that
> we use the input receive classification to influence the spread on transmit,
> I think things like this bonding case should remember the rxhash setting
> before they override it and then restore that value right before invoking
> dev_queue_xmit().
> 
Ok, I can respin the patch to do that.  I'll handle it in the AM.

Thanks
Neil


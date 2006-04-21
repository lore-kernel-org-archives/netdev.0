From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit
 buffers
Date: Fri, 21 Apr 2006 08:28:06 -0700
Message-ID: <1145633287.3194.10.camel@rh4>
References: <1145578214.3195.6.camel@rh4>
 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
 <20060421024024.GA29644@gondor.apana.org.au>
 <1145582676.3195.18.camel@rh4>
 <20060421132758.GA26161@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, shawvrana@gmail.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:58119 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751316AbWDURI2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 13:08:28 -0400
To: "Andy Gospodarek" <andy@greyhouse.net>
In-Reply-To: <20060421132758.GA26161@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-21 at 09:27 -0400, Andy Gospodarek wrote:

> 
> Isn't the only possibility for a linkwatch deadlock when the
> __LINK_STATE_LINKWATCH_PENDING but is set in dev->state?  

This device that you're about to close may be on the linkwatch list, or
other devices may also be on the linkwatch list. As long as
linkwatch_event is in front of your driver's task on the same workqueue,
it will deadlock.

> 
> Off the top of my head...
> 
> Would it be interesting to change the calls for flush_scheduled_work()
> to a new function net_flush_scheduled_work() with the intent on
> eventually creating new a new work queue but temporarily just checking
> to make sure there are no linkwatch events pending and if there are
> allowing them to run first before calling flush_scheduled_work()?
> 

Using the same workqueue and holding the rtnl_lock, I'm not sure how you
can let linkwatch_event run first without deadlocking.


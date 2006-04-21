From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit buffers
Date: Fri, 21 Apr 2006 09:27:58 -0400
Message-ID: <20060421132758.GA26161@gospo.rdu.redhat.com>
References: <1145578214.3195.6.camel@rh4> <E1FWlWa-0007hN-00@gondolin.me.apana.org.au> <20060421024024.GA29644@gondor.apana.org.au> <1145582676.3195.18.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, shawvrana@gmail.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:10399 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932297AbWDUN2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 09:28:25 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1145582676.3195.18.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 06:24:36PM -0700, Michael Chan wrote:
> On Fri, 2006-04-21 at 12:40 +1000, Herbert Xu wrote:
> 
> > One simple solution is to establish a separate queue for RTNL-holding
> > users or vice versa for non-RTNL holding networking users.  That
> > would allow the drivers to safely flush the non-RTNL queue while
> > holding the RTNL.
> 
> You mean a separate workqueue for net drivers to use instead of the
> keventd_wq? Yeah, I think that'll work. Each driver can also create its
> own workqueue but that may be a bit more wasteful.
> 

Isn't the only possibility for a linkwatch deadlock when the
__LINK_STATE_LINKWATCH_PENDING but is set in dev->state?  

Off the top of my head...

Would it be interesting to change the calls for flush_scheduled_work()
to a new function net_flush_scheduled_work() with the intent on
eventually creating new a new work queue but temporarily just checking
to make sure there are no linkwatch events pending and if there are
allowing them to run first before calling flush_scheduled_work()?

This probably isn't a perfect solution, but I thought I'd throw it out
there and see what you think....

-andy



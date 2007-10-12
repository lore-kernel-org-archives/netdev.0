From: David Miller <davem@davemloft.net>
Subject: Re: Regression in net-2.6.24?
Date: Fri, 12 Oct 2007 01:39:23 -0700 (PDT)
Message-ID: <20071012.013923.72710726.davem@davemloft.net>
References: <1192159036.6889.6.camel@dell>
	<20071011.194009.48528774.davem@davemloft.net>
	<1192179253.4788.14.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, takano@axe-inc.co.jp,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751160AbXJLIjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:39:24 -0400
In-Reply-To: <1192179253.4788.14.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 12 Oct 2007 01:54:13 -0700

> On Thu, 2007-10-11 at 19:40 -0700, David Miller wrote:
> > Hmmm, the old code didn't do that and seemingly has the same
> > problem.  Also, if you look at the before-patch code and think
> > about what it does if we ->poll() multiple times for a single
> > interrupt the side-effects are essentially the same.
> > 
> 
> No, the old code before tonight's patch did this:
> 
> if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
> 	tp->last_tag = sblk->status_tag;
> 	rmb();
> }
> 
> before checking for more work.  The rmb() is there to make sure that the
> status tag is read and stored before we check for more work.

No I understand, thanks!

> [TG3]: Refine napi poll loop.
> 
> Need to read and store sblk->status_tag before checking for more work.
> The status tag is later written back to the hardware when enabling
> interrupts to acknowledge how much work has been processed.  If the
> order is reversed, we can end up acknowledging work we haven't
> processed.
> 
> When we detect tx error, it is more correct to return the rx
> work_done so far instead of 0.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I'll apply this, thanks a lot!

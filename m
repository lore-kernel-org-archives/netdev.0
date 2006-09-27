From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 6/9][TG3]: Add basic 5906 support.
Date: Wed, 27 Sep 2006 16:21:01 -0700
Message-ID: <1159399261.3411.45.camel@rh4>
References: <1159389299.3411.23.camel@rh4>
 <20060927.160836.74560378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:45329 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1031220AbWI0XY2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:24:28 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060927.160836.74560378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 16:08 -0700, David Miller wrote:

> > @@ -491,6 +513,9 @@ static inline void tg3_cond_int(struct t
> >  	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
> >  	    (tp->hw_status->status & SD_STATUS_UPDATED))
> >  		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
> > +	else
> > +		tw32(HOSTCC_MODE, tp->coalesce_mode |
> > +		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
> >  }
> >  
> >  static void tg3_enable_ints(struct tg3 *tp)
> 
> Why are we forcing a coalescing event here now?  This seems
> to apply in quite a large number of cases.  It will trigger
> if either:
> 
> 1) using tagged status
> 2) SD_STATUS_UPDATED is not indicated in the status block
> 
> In particular, how is this a 5906 specific support change
> when there are no 5906 or other chipset conditionals guarding
> the logic here?
> 

It was found that on rare occasions, the 5906 will miss the first
interrupt after reset without the COALESCE_NOW.  It was also felt that
other chips may also have this problem, and therefore it is a good and a
safe thing to do for all chips using the tagged mode.

This call is only made after resetting the chip, and so there's no
performance impact at all during run-time.


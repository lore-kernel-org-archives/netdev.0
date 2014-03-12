From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCHv6 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 12 Mar 2014 14:57:49 -0500
Message-ID: <008601cf3e2d$583b5e90$08b21bb0$@opengridcomputing.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com> <20140312.155125.1045693666130935765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: "'David Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140312.155125.1045693666130935765.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> Sent: Wednesday, March 12, 2014 2:51 PM
> To: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org;
> dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org; swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org; leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org;
> santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org; kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org; nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
> Subject: Re: [PATCHv6 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
> 
> From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> Date: Wed, 12 Mar 2014 21:20:15 +0530
> 
> > V6:
> >    In patch 8/31, move the existing neigh_release() call right before the
> >    if(!e) test, that way you don't need a completely new label and code block
> >    to fix this bug - thanks to review by David Miller
> >    In patch 15/31, use %pad to print dma_addr - thanks to review by Joe Perches
> >    In patch 10/31, add the "STOPPED" state string to db_state_str - thanks
> >    to review by Steve Wise
> >    In patch 10/31, t4_db_dropped() needs to disable dbs and send DB_FULL
> >    event to iw_cxgb4 - thanks to review by Steve Wise
> > V5:
> >    Dropped patch "cxgb4: use spinlock_irqsave/spinlock_irqrestore for db lock".
> 
> I do not see the spinlock patch reinstated, part of it was correct and
> fixed a real bug.  For the second time, I only stated that parts of it
> were superfluous, not all of it.
> 

Ok we can reinstate this patch and remove the bits from 10/31 if that's what you prefer.

Steve.

BTW: From my earlier reply explaining that we didn't drop the needed fixes:

The remaining changes from the removed patch are moved into patch 10/31
(Doorbell Drop Avoidance Bug Fixes).  10/31 has the driver call
disable_txq_db() from an interrupt handler, and I thought it would be
better to put all the changes to fix how the db lock is acquired into
this one patch.   

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 09/14] tg3: Improve small packet
 performance
Date: Wed, 4 Aug 2010 15:46:07 -0700
Message-ID: <20100804224607.GA4881@mcarlson.broadcom.com>
References: <1280784368-4226-9-git-send-email-mcarlson@broadcom.com>
 <20100804222741.GA18708@kryten>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"Michael Chan" <mchan@broadcom.com>
To: "Anton Blanchard" <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3218 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855Ab0HDWqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 18:46:54 -0400
In-Reply-To: <20100804222741.GA18708@kryten>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 03:27:41PM -0700, Anton Blanchard wrote:
> 
> Hi,
> 
> Just saw this go in:
>   
> >  static inline u32 tg3_tx_avail(struct tg3_napi *tnapi)
> >  {
> > -	smp_mb();
> > +	/* Tell compiler to fetch tx indices from memory. */
> > +	barrier();
> >  	return tnapi->tx_pending -
> >  	       ((tnapi->tx_prod - tnapi->tx_cons) & (TG3_TX_RING_SIZE - 1));
> >  }
> 
> Which worries me. Are we sure we don't need any ordering (eg smp_rmb)?
> A compiler barrier does nothing to ensure two loads are ordered.
> 
> Anton

The compiler barrier makes sure the loads stay roughly in the same
location.  In the places where the ordering really matters, we have the
memory barrier inlined into the calling code.  In the rest of the
places, we can relax the ordering requirement because the final value is
just used as an estimate.


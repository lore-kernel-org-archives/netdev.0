From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: 5717 support commit is buggy
Date: Fri, 11 Sep 2009 16:11:54 -0700
Message-ID: <20090911231154.GA12542@xw6200.broadcom.net>
References: <20090911.151554.181296228.davem@davemloft.net>
 <20090911.154125.182458823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1426 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbZIKXMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 19:12:15 -0400
In-Reply-To: <20090911.154125.182458823.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 03:41:25PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 11 Sep 2009 15:15:54 -0700 (PDT)
> 
> > I'm about to do some tests, but I suspect it's this change:
> > 
> > @@ -111,7 +111,8 @@
> >   * replace things like '% foo' with '& (foo - 1)'.
> >   */
> >  #define TG3_RX_RCB_RING_SIZE(tp)	\
> > -	((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)
> > +	(((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) && \
> > +	  !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) ? 512 : 1024)
> >  
> >  #define TG3_TX_RING_SIZE		512
> >  #define TG3_DEF_TX_RING_PENDING		(TG3_TX_RING_SIZE - 1)
> > 
> > and thus an incorrect RCB ring size is being used which eventually
> > locks up the card.
> 
> Confirmed, reverting that part of the change makes my card
> work again.
> 
> Broadcom folks, that is the correct test?  This needs to be fixed
> urgently.

The test is correct, but the results are transposed.  The 512 and 1024
should be reversed.  I'll cook up a patch.


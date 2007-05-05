From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/11][TG3]: Add ASPM workaround.
Date: Sat, 05 May 2007 13:10:05 -0700 (PDT)
Message-ID: <20070505.131005.85669827.davem@davemloft.net>
References: <1178326514.4859.25.camel@dell>
	<463BD269.7010501@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933285AbXEEUKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 16:10:18 -0400
In-Reply-To: <463BD269.7010501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 May 2007 20:40:09 -0400

> Michael Chan wrote:
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -3019,6 +3019,15 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
> >  		}
> >  	}
> >  
> > +	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND) {
> > +		u32 val = tr32(0x7d28);
> > +		if (!netif_carrier_ok(tp->dev))
> > +			val = (val & ~0x0000ff00) | tp->pwrmgmt_thresh;
> > +		else
> > +			val |= 0x0000ff00;
> > +		tw32(0x7d28, val);
> > +	}
> > +
> >  	return err;
> >  }
> >  
> > @@ -10997,6 +11016,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> >  	 */
> >  	tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
> >  
> > +	if (tp->tg3_flags & TG3_FLAG_ASPM_WORKAROUND)
> > +		tp->pwrmgmt_thresh = tr32(0x7d28) & 0x0000ff00;
> 
> 
> NAK -- magic numbers.
> 
> Please create a named constant for the register at 0x7d28.

Agree, please fix this patch up Michael.

Thanks.

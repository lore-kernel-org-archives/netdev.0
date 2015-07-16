From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] tg3:Add error handling to the function
 tg3_test_loopback
Date: Thu, 16 Jul 2015 12:20:35 -0700
Message-ID: <1437074435.3152.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1437072690-21048-1-git-send-email-xerofoify@gmail.com>
	 <1437074332.3152.0.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <prashant@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437074332.3152.0.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-16 at 12:18 -0700, Michael Chan wrote: 
> On Thu, 2015-07-16 at 14:51 -0400, Nicholas Krause wrote: 
> > This adds proper error handling for if the calls to the function
> > tg3_phy_lpbk_set fail by returning -EIO by assigning the return
> > value to the variable err and if it equals anything other then
> > zero jumps to the goto label done as no other work can be handled
> > internally in the function tg3_test_loopback.
> > 
> > Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Your indentation doesn't look right.  Other than that, it is ok.

> 
> > ---
> >  drivers/net/ethernet/broadcom/tg3.c | 12 ++++++++----
> >  1 file changed, 8 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > index 73c934c..8584cb7 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -13625,8 +13625,10 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
> >  	    !tg3_flag(tp, USE_PHYLIB)) {
> >  		int i;
> >  
> > -		tg3_phy_lpbk_set(tp, 0, false);
> > -
> > +		err = tg3_phy_lpbk_set(tp, 0, false);
> > +			if (err)
> > +				goto done;
> > +
> >  		/* Wait for link */
> >  		for (i = 0; i < 100; i++) {
> >  			if (tr32(MAC_TX_STATUS) & TX_STATUS_LINK_UP)
> > @@ -13644,8 +13646,10 @@ static int tg3_test_loopback(struct tg3 *tp, u64 *data, bool do_extlpbk)
> >  			data[TG3_PHY_LOOPB_TEST] |= TG3_JMB_LOOPBACK_FAILED;
> >  
> >  		if (do_extlpbk) {
> > -			tg3_phy_lpbk_set(tp, 0, true);
> > -
> > +			err = tg3_phy_lpbk_set(tp, 0, true);
> > +
> > +				if (err)
> > +					goto done;
> >  			/* All link indications report up, but the hardware
> >  			 * isn't really ready for about 20 msec.  Double it
> >  			 * to be sure.
> 

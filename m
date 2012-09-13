From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [net PATCH v2 1/7] bnx2x: Avoid sending multiple statistics
 queries
Date: Thu, 13 Sep 2012 20:35:40 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F2B73D8@SJEXCHMB06.corp.ad.broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
 <1347374054-16730-2-git-send-email-yuvalmin@broadcom.com>
 <20120913.161711.2180618409918407558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3224 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757502Ab2IMUfv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:35:51 -0400
In-Reply-To: <20120913.161711.2180618409918407558.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, September 13, 2012 11:17 PM
> To: Yuval Mintz
> Cc: netdev@vger.kernel.org; Dmitry Kravkov; Eilon Greenstein
> Subject: Re: [net PATCH v2 1/7] bnx2x: Avoid sending multiple statistics queries
> 
> From: "Yuval Mintz" <yuvalmin@broadcom.com>
> Date: Tue, 11 Sep 2012 17:34:08 +0300
> 
> > From: Dmitry Kravkov <dmitry@broadcom.com>
> >
> > During traffic when DCB is enabled, it is possible for multiple instances
> > of statistics queries to be sent to the chip - this may cause the FW to assert.
> >
> > This patch prevents the sending of an additional instance of statistics query
> > while the previous query hasn't completed.
> >
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> This change results in no change in behavior as far as I can tell.
> 
> > -	if (bnx2x_storm_stats_update(bp) && (bp->stats_pending++ == 3)) {
> > -		BNX2X_ERR("storm stats were not updated for 3 times\n");
> > -		bnx2x_panic();
> > +	if (bnx2x_storm_stats_update(bp)) {
> > +		if (bp->stats_pending++ == 3) {
> > +			BNX2X_ERR("storm stats were not updated for 3
> times\n");
> > +			bnx2x_panic();
> > +		}
> 
> There is no difference between:
> 
> 	if (A && B) {
> 		C;
> 	}
> 
> and:
> 
> 	if (A) {
> 		if (B) {
> 			C;
> 		}
> 	}
> 
> Yet that's exactly what is happening in this patch.
> 
> And such a do-nothing change is certainly not appropriate this late in
> the -rc series.
> 
> I'm tossing this entire series, please sort this out and submit
> the real actual critical bug fixes.
return statement is not seen in the patch:
Before the change we returned from the function if (A &&B)
Now we return even if (A)

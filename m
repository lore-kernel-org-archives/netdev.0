From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 5/9][TG3]: Add tg3_poll_fw().
Date: Wed, 27 Sep 2006 13:49:23 -0700
Message-ID: <1159390163.3411.29.camel@rh4>
References: <1159389289.3411.22.camel@rh4> <451AE346.9010801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:15879 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030825AbWI0Uwr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:52:47 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <451AE346.9010801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 16:47 -0400, Jeff Garzik wrote:
> Michael Chan wrote:
> > +	/* Chip might not be fitted with firmware.  Some Sun onboard
> > +	 * parts are configured like that.  So don't signal the timeout
> > +	 * of the above loop as an error, but do report the lack of
> > +	 * running firmware once.
> > +	 */
> > +	if (i >= 100000 &&
> > +	    !(tp->tg3_flags2 & TG3_FLG2_NO_FWARE_REPORTED)) {
> > +		tp->tg3_flags2 |= TG3_FLG2_NO_FWARE_REPORTED;
> > +
> > +		printk(KERN_INFO PFX "%s: No firmware running.\n",
> > +		       tp->dev->name);
> > +	}
> > +
> > +	return 0;
> 
> You need to actually return failure, for the failure case.
> 
> Currently, this function is written to return an error code, but always 
> returns zero.
> 
It's actually not a failure.  It was decided that we'll just print a
message once and continue.  Some SUN onboard chips do not have firmware.

In the next patch (6/9) where we support a new chip with a new firmware
polling method, it can return -ENODEV.


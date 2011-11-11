From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V2 01/14] clk: add helper functions clk_prepare_enable
 and clk_disable_unprepare
Date: Fri, 11 Nov 2011 10:15:56 +0100
Message-ID: <20111111091556.GI16886@pengutronix.de>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
 <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
 <20111111084950.GH16886@pengutronix.de>
 <20111111090546.GC14617@b20223-02.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amit.kucheria@canonical.com, linux@arm.linux.org.uk,
	kernel@pengutronix.de, netdev@vger.kernel.org,
	linux-mmc@vger.kernel.org, ben-linux@fluff.org,
	eric.miao@linaro.org, linux-i2c@vger.kernel.org,
	linux-serial@vger.kernel.org, cjb@laptop.org,
	linux-arm-kernel@lists.infradead.org, alan@linux.intel.com
To: Richard Zhao <richard.zhao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39891 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558Ab1KKJQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 04:16:08 -0500
Content-Disposition: inline
In-Reply-To: <20111111090546.GC14617@b20223-02.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2011 at 05:05:47PM +0800, Richard Zhao wrote:
> On Fri, Nov 11, 2011 at 09:49:50AM +0100, Sascha Hauer wrote:
> > On Fri, Nov 11, 2011 at 09:10:16AM +0800, Richard Zhao wrote:
> > > Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> > > ---
> > >  include/linux/clk.h |   19 +++++++++++++++++++
> > >  1 files changed, 19 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/include/linux/clk.h b/include/linux/clk.h
> > > index 7213b52..63985f7 100644
> > > --- a/include/linux/clk.h
> > > +++ b/include/linux/clk.h
> > > @@ -107,6 +107,25 @@ static inline void clk_unprepare(struct clk *clk)
> > >  }
> > >  #endif
> > >  
> > > +static inline int clk_prepare_enable(struct clk *clk)
> > > +{
> > > +	int ret;
> > > +
> > > +	ret = clk_prepare(clk);
> > > +	if (!ret)
> > > +		ret = clk_enable(clk);
> > > +	if (ret)
> > > +		clk_unprepare(clk);
> > 
> > As Baruch already pointed out this is hard to read. Also it contains a
> > bug. When clk_prepare fails clk_unprepare is called afterwards.
> > 
> > Hint: Kernel guys are not afraid of having multiple return statements
> > in a function, instead they like it when something is handled early
> > without having to read the rest of the function.
> {
> 	int ret;
> 
> 	ret = clk_prepare(clk);
> 	if (ret)
> 		return ret;
> 	ret = clk_enable(clk);
> 	if (ret)
> 		clk_unprepare(clk);
> 	return ret;

Yes, looks good.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

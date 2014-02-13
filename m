From: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: Re: [PATCH v2 1/2] dp83640: Support a configurable number of
 periodic outputs
Date: Thu, 13 Feb 2014 15:21:51 +0100
Message-ID: <1392301311.2585.9.camel@e37108.spectralink.com>
References: <1392132562-23644-1-git-send-email-stefan.sorensen@spectralink.com>
	 <1392132562-23644-2-git-send-email-stefan.sorensen@spectralink.com>
	 <20140211200922.GA4254@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140211200922.GA4254@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-11 at 21:09 +0100, Richard Cochran wrote:

> > -#define EXT_EVENT	1
> 
> Regarding this EXT_EVENT thing ...
> 
> > @@ -430,12 +419,12 @@ static int ptp_dp83640_enable(struct ptp_clock_info *ptp,
> >  	switch (rq->type) {
> >  	case PTP_CLK_REQ_EXTTS:
> >  		index = rq->extts.index;
> > -		if (index < 0 || index >= N_EXT_TS)
> > +		if (index < 0 || index >= n_ext_ts)
> >  			return -EINVAL;
> > -		event_num = EXT_EVENT + index;
> > +		event_num = index;
> 
> there was a mapping between the "event numbers" and the external time
> stamp channels. I don't remember off the top of my head why this these
> two differ by one, but there was a good reason.

I haven't seen anything in the documentation regarding this, output
triggers 0 and 1 are special, but the events should all behave the same.
Could be be a mixup between events and pins? Pin0 means disable the
event.

> Are you sure this is still working with this change?

It has been running with event 0 in one of our products for at least the
last 3 months....

> I am especially wondering about the event decoding here:
> 
> > @@ -642,7 +631,7 @@ static void recalibrate(struct dp83640_clock *clock)
> >  
> >  static inline u16 exts_chan_to_edata(int ch)
> >  {
> > -	return 1 << ((ch + EXT_EVENT) * 2);
> > +	return 1 << ((ch) * 2);
> >  }
> 
> Maybe I am just paranoid, but can you remind me how these event
> numbers are supposed to work, before and after the change?

The mapping was hardcoded to map events 0-5 to event channels 1-6, the
periodic output trigger at channel 6 and the calibration event+trigger
both at channel 7.

The patch will (at least in v3 that I will post shortly) change both the
event and trigger mapping to a direct mapping and keep the calibration
at channel 7.

Stefan

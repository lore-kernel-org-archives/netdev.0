From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 4/7] sfc: Add support for IEEE-1588 PTP
Date: Fri, 20 Jul 2012 17:30:16 +0200
Message-ID: <20120720153016.GB2771@netboy.at.omicron.at>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
 <1342635693.2617.56.camel@bwh-desktop.uk.solarflarecom.com>
 <20120719142558.GB24484@localhost.localdomain>
 <500827EF.208@solarflare.com>
 <20120720063102.GB2330@netboy.at.omicron.at>
 <500921C2.1080001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Andrew Jackson <ajackson@solarflare.com>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:52969 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab2GTPaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:30:24 -0400
Received: by wibhm11 with SMTP id hm11so704204wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 08:30:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <500921C2.1080001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 10:15:46AM +0100, Stuart Hodgson wrote:
> 
> Do you mean using the PPS kernel consumer to govern the system time?

Well, I meant just using the PPS subsystem, which does not necessarily
mean that the kernel consumer has to be used. In my experience, it is
better to handle the servo in user space, but in any case, the user
has the choice of what to do.

> >>>> +	ptp_pps_evt.type = PTP_CLOCK_EXTTS;
> >>>> +	ptp_pps_evt.timestamp = ktime_to_ns(gen_time_host);
> >>>> +	ptp_clock_event(ptp->phc_clock, &ptp_pps_evt);

> In order for a PPS to arrive at the kernel consumer ptp_clock_event
> needs to be called with PTP_CLOCK_PPS. This then calls pps_get_ts
> and stamps the event with the current system time, not the time
> that was put into the event.

Oops, I meant PTP_CLOCK_PPS. I overlooked that your code is making an
external timestamp event, but the basic idea is similar.

> Using PTP_CLOCK_EXTTS the PPS is visible to userspace via a read
> on the phc device and can then be used in our modified ptpd2.

How does your program use this information?

> > ... why can't you also just set the time?
> 
> Our hardware can only have an offset applied to the clock. In order to set time
> we need to know the time now, then work out and offset to get to the target time.
> At the point that we apply this offset the clock will have moved on and not be
> set to the target time. We can apply some measured average times to the offset
> to get closer but with this hardware settime will not leave the NIC clock at the
> desired time.

It does not matter if setting the time introduces a small error. That
usually happens, but it is no big deal, since the servo in the PTP
stack will correct the error.

Thanks,
Richard

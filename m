From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC net-next v1 0/9] ptp: dynamic pin control
Date: Wed, 12 Mar 2014 15:46:02 +0100
Message-ID: <20140312144602.GB10256@netboy>
References: <cover.1394307303.git.richardcochran@gmail.com>
 <D4F856CB7308D0C94855B452@[172.22.2.41]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <D4F856CB7308D0C94855B452@[172.22.2.41]>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 09:21:00AM +0100, Christian Riesch wrote:
> 
> Do you think it is possible to extend this in the future, e.g. for
> selecting the polarity of periodic output signals  or for time
> stamping of external signals (rising edge/falling edge), or duty
> cycles of the periodic signal other than 50%? How could this be
> done? Using the reserved fields in struct ptp_pin_desc?

Yes, this can be done, but this relates to the ptp_xyz_request ioctls
and not to the ptp_pin_desc. You asked for three things. Here is how
one might implement them.

1. selecting the polarity of periodic output signals

   ptp_perout_request.flags (new flag)

2. time stamping of external signals (rising edge/falling edge)

   This is already supported in the ptp_extts_request.flags field.
   The drivers just need to implement it.

3. duty cycles of the periodic signal other than 50%?

   Maybe using one of the ptp_perout_request.rsv fields.
 
> Do you think the concept allows an extension for single pulse
> output, e.g. programming a pin to output a single pulse at a given
> time, as supported by the DP83640?

Yes, either a new ioctl or maybe ptp_perout_request.flags with a
ONE-SHOT flag.

> If several DP83640 are connected together with the calibration
> function, only the GPIOs of the master device can be used, right? I
> guess this could also be extended in the future to use the GPIOs of
> all DP83640, right? Or do you see a problem with your concept here?

If the driver would combine all of the pins and functions over all the
devices, that would be best. I think it would be tricky to implement,
since the driver probe() function doesn't know how many more phyters
to expect.

Thanks,
Richard

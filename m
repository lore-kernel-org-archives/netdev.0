From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH RFC net-next v1 0/9] ptp: dynamic pin control
Date: Wed, 12 Mar 2014 09:21:00 +0100
Message-ID: <D4F856CB7308D0C94855B452@[172.22.2.41]>
References: <cover.1394307303.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Stefan_S=C3=B8rensen?= <stefan.sorensen@spectralink.com>
To: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394307303.git.richardcochran@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

--On March 08, 2014 20:42 +0100 Richard Cochran <richardcochran@gmail.com> 
wrote:

> This patch series introduces a way of changing the auxiliary PTP
> Hardware Clock functions (periodic output signals and time stamping
> external signals) at run time. In the past on the netdev list, we have
> discussed other ways to handle this, such as module parameters and
> ethtool. This series implements a new PHC ioctl because that is the
> most natural way. Users already activate the auxiliary functions via
> the ioctls. The sysfs interface has also been expanded so that the pin
> configuration can be programmed using shell scripts.

I did a few tests on one of my boards, everything works so far! Thanks for 
the patchset, I like it!

> The first patch adds the new ioctls. The PHC subsystem does most of
> the work of maintaining the function-to-pin mapping. Drivers will only
> need to allocate and initialize a pin configuration table and also
> provide a new method that validates a particular assignment.
>
> Patches 5 and 6 just clean up a couple of issues in the phyter driver,
> and the remaining patches actually hook the phyter's pins into the new
> system.
>
> Comments and questions are most welcome.

Do you think it is possible to extend this in the future, e.g. for 
selecting the polarity of periodic output signals or for time stamping of 
external signals (rising edge/falling edge), or duty cycles of the periodic 
signal other than 50%? How could this be done? Using the reserved fields in 
struct ptp_pin_desc?

Do you think the concept allows an extension for single pulse output, e.g. 
programming a pin to output a single pulse at a given time, as supported by 
the DP83640?

If several DP83640 are connected together with the calibration function, 
only the GPIOs of the master device can be used, right? I guess this could 
also be extended in the future to use the GPIOs of all DP83640, right? Or 
do you see a problem with your concept here?

Best regards,
Christian

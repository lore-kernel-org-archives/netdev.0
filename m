From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V11 2/4] ptp: Added a clock that uses the eTSEC found
 on the MPC85xx.
Date: Thu, 24 Feb 2011 17:39:44 +0100
Message-ID: <20110224163944.GA15234@riccoc20.at.omicron.at>
References: <cover.1298447722.git.richard.cochran@omicron.at>
 <be1f5e801e8cd0145dd23aadae7c2055bb3c1d47.1298447722.git.richard.cochran@omicron.at>
 <20110223165058.GE14597@angua.secretlab.ca>
 <20110223112612.30071995@schlenkerla>
 <20110223175459.GH14597@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110223175459.GH14597-MrY2KI0G/OVr83L8+7iqerDks+cytr/Z@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 10:54:59AM -0700, Grant Likely wrote:
> On Wed, Feb 23, 2011 at 11:26:12AM -0600, Scott Wood wrote:

> > The eTSEC revision is probeable as well, but due the way PTP is described as
> > a separate node, the driver doesn't have straightforward access to those
> > registers.
> 
> Ignorant question: Should the ptp be described as a separate node?

Well, the PTP Hardware Clock function is logically separate from the
MAC function. PHCs can be implemented in the MAC, in the PHY, or in
between in an FPGA on MII bus.

If the PHC is in the MAC, then it might be wise to implement one
driver that offers both the MAC and the PHC.

In the case of gianfar, it is not really necessary to combine the PHC
into the gianfar driver, since the registers are pretty well
separated. Also, given the size and complexity (and churn over time)
of the gianfar driver, I decided to keep the PHC separate.

Right now, the driver correctly handles all the clock revisions in the
boards that I have (mpc8313, mpc8572, p2020ds, p2020rdb).

If checking the revision becomes important, then we can always export
a function from gianfar to provide this.

Thanks,

Richard

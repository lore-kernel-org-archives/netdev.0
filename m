From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] drivers: ptp: Include new header file in ptp_pch.c
Date: Thu, 19 Dec 2013 08:27:59 +0100
Message-ID: <20131219072757.GB4281@netboy>
References: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
 <20131216085839.GA8303@netboy>
 <20131218.174359.2230195267384857675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rashika.kheria@gmail.com, linux-kernel@vger.kernel.org,
	dvhart@linux.intel.com, joe@perches.com,
	andriy.shevchenko@linux.intel.com, vfalico@redhat.com,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131218.174359.2230195267384857675.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 18, 2013 at 05:43:59PM -0500, David Miller wrote:
> 
> I think this begs an even more fundamental question, why isn't the PTP
> driver abstraction providing the necessary methods and interfaces so
> that pch_gbe doesn't have to call into the ptp_pch.c code directly?

Really it is more of a driver issue. For MAC based PTP clocks, they
are so tightly coupled to the MAC driver that it is better *not* to
have the PTP functions in a separate module. Instead, if having the
PTP stuff optional makes sense, then the PTP parts are just a compile
time option in the MAC driver. This is how the other MAC drivers with
optional PTP are structured.

> Moving ptp_pch.c elsehwere is not desirable, it's a PTP driver so
> it belongs under drivers/ptp.
> 
> Someone who understands all of these components needs to sort this
> out cleanly, this patch isn't it.

I am getting a bit tired of all the trouble over the past year caused
by this particular driver. After it got merged, the original authors
disappeared. I would really like to see this driver follow the pattern
of bfin_mac, ti/cpts, and tile. Maybe I'll have to do it myself, like
the Red Hen.

Thanks,
Richard

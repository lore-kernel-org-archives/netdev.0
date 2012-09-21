From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 20:01:46 +0100
Message-ID: <1348254106.2521.56.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
	 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
	 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120921173709.GB6129@netboy.at.omicron.at>
	 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
	 <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120921181115.GE6129@netboy.at.omicron.at>
	 <1348251783.2521.42.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120921184035.GF6129@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24713 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933088Ab2IUTBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:01:50 -0400
In-Reply-To: <20120921184035.GF6129@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 20:40 +0200, Richard Cochran wrote:
> On Fri, Sep 21, 2012 at 07:23:03PM +0100, Ben Hutchings wrote:
> > 
> > I think what I'm still missing from you is some explanation of what the
> > 'clock name' is meant to be used as - a type name, a unique identifier,
> > a 'friendly name' for listing clocks in a user interface?
> 
> The original idea was a type/friendly kind of thing.
> 
> Imagine you are the admin of some random box that should run PTP. You
> do 'cat /sys/class/ptp/ptp0/clock_name' and see "gianfar clock". Then
> you think to yourself, "Excellent, I know that one, it works great,
> and I can even get a PPS output."
> 
> But if you saw "IXP46X timer" then you would think, "Forget it, this
> will never work."
> 
> That was the idea.
> 
> But before the ethtool thing came along, people started putting MAC
> addresses in that string, and it continued even after the ethtool
> method appeared. I wanted to correct the MAC abuses, but then I
> thought you were concurring with putting some kind of semi-unique
> device ID there.

I was confused about whether it was actually meant to be unique.

The ethtool command is useful but setting the parent device may be even
more useful, e.g. you will be able to write udev rules for PHC devices
based on the parent device's identity.

> I really don't care too much about the clock_name anyhow, because I
> always know my own hardware. I don't mind changing it from type-string
> or friendly-name to device ID, if people think that is more useful.

I don't mind either, just so long as the rule is either (1) implemented
in the PTP core code or (2) made very clear to driver writers.

The lack of a parent for the IXP device makes (1) hard to do well.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

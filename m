From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Sat, 22 Sep 2012 07:43:46 +0200
Message-ID: <20120922054345.GA6124@netboy.at.omicron.at>
References: <cover.1348245523.git.richardcochran@gmail.com>
 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921173709.GB6129@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
 <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921181115.GE6129@netboy.at.omicron.at>
 <1348251783.2521.42.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921184035.GF6129@netboy.at.omicron.at>
 <1348254106.2521.56.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:65484 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab2IVFn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 01:43:56 -0400
Received: by wibhi8 with SMTP id hi8so2900217wib.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 22:43:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348254106.2521.56.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 08:01:46PM +0100, Ben Hutchings wrote:
> 
> The ethtool command is useful but setting the parent device may be even
> more useful, e.g. you will be able to write udev rules for PHC devices
> based on the parent device's identity.

Thinking about this a bit more, it makes no sense to put the parent
device name into clock_name, because that information is redundant.

  # ls -l /sys/class/ptp/ptp0/
  -r--r--r--    1 root root 8192 Jan  1 00:00 clock_name
  -r--r--r--    1 root root 8192 Jan  1 00:00 dev
  lrwxrwxrwx    1 root root    0 Jan  1 00:00 device -> ../../../fec-1:01

I agree that the parent device is useful, and I will add it. However,
I will leave the clock_name as it is, adding a bit more prose to the
ABI description.

The one case where clock_name becomes really important is when you
have a PHY clock, like in the above example, since it provides a way
to see that the clock is *not* related to the MAC.

Thanks,
Richard

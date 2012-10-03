From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
 dependency.
Date: Wed, 3 Oct 2012 22:45:10 +0100
Message-ID: <1349300710.2763.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <506546A7.7030500@linux.intel.com>
	 <20120928.024621.1635385815700269914.davem@davemloft.net>
	 <50654A62.5090003@linux.intel.com>
	 <20121002.222238.1580734803370802133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <haicheng.li@linux.intel.com>, <netdev@vger.kernel.org>,
	<tshimizu818@gmail.com>, <linux-kernel@vger.kernel.org>,
	<haicheng.lee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56558 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756347Ab2JCVpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 17:45:14 -0400
In-Reply-To: <20121002.222238.1580734803370802133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 22:22 -0400, David Miller wrote:
> From: Haicheng Li <haicheng.li@linux.intel.com>
> Date: Fri, 28 Sep 2012 14:57:38 +0800
> 
> > On 09/28/2012 02:46 PM, David Miller wrote:
> >> From: Haicheng Li<haicheng.li@linux.intel.com>
> >> Date: Fri, 28 Sep 2012 14:41:43 +0800
> >>
> >>> On 09/28/2012 06:09 AM, David Miller wrote:
> >>>> Look at how other people submit patches, do any other patch
> >>>> submissions
> >>>> look like your's having all of this metadata in the message body:
> >>> I'm sorry for it.
> >>>
> >>>> As for this specific patch:
> >>>>
> >>>>> -	depends on PTP_1588_CLOCK_PCH
> >>>>> +	depends on PTP_1588_CLOCK_PCH = PCH_GBE
> >>>>
> >>>> This is not the correct way to ensure that the module'ness of one
> >>>> config option meets the module'ness requirements of another.
> >>>> The correct way is to say something like "&&   (PCH_GBE || PCH_GBE=n)"
> >>>
> >>> This case is a little bit tricky than usual, with PCH_PTP selected,
> >>> the valid config would be either "PTP_1588_CLOCK_PCH=PCH_GBE=m" or
> >>> "PTP_1588_CLOCK_PCH=PCH_GBE=y", and PTP_1588_CLOCK_PCH depends on
> >>> PCH_GBE.
> >>
> >> And a simple "&&  PCH_GBE" should accomplish this, no?
> > No sir. it's actually same with the original Kconfig (by a if
> > PCH_GBE"), it just failed with this config:
> > 
> >         CONFIG_PCH_GBE=y
> >         CONFIG_PCH_PTP=y
> >         CONFIG_PTP_1588_CLOCK=m
> 
> The correct fix is to make the Kconfig entry for PCH_PTP use
> a "select PTP_1588_CLOCK" instead of "depends PTP_1588_CLOCK"
> 
> I'll apply this fix.
> 
> The is another, extremely convoluted, way to do this, which is
> what the SFC driver does which is:
> 
> depends on SFC && PTP_1588_CLOCK && !(SFC=y && PTP_1588_CLOCK=m)
> 
> but that looks horrible to me.

I thought of it as being a peripheral feature (which most Solarflare
hardware doesn't implement) so it made sense for SFC_PTP to be optional
like SFC_MTD and so on.  But I'm quite happy to use a select instead, if
you want that to be the convention for all drivers implementing PHC.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

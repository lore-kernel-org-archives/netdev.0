From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: update get_rx_ntuple to
 correctly interpret string count
Date: Wed, 05 Jan 2011 15:26:56 +0000
Message-ID: <1294241216.15866.14.camel@bwh-desktop>
References: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com>
	 <1294185662.3636.61.camel@bwh-desktop>  <4D23C423.3050609@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26892 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab1AEP06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 10:26:58 -0500
In-Reply-To: <4D23C423.3050609@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-04 at 17:06 -0800, Alexander Duyck wrote:
> On 1/4/2011 4:01 PM, Ben Hutchings wrote:
> > On Tue, 2011-01-04 at 15:29 -0800, Alexander Duyck wrote:
> >> Currently any strings returned via the get_rx_ntuple call will just be
> >> dropped because the num_strings will be zero.  In order to correct this I
> >> am updating things so that the return value of get_rx_ntuple is the number
> >> of strings that were written, or a negative value if there was an error.
> > [...]
> >
> > Nothing implements ethtool_ops::get_rx_ntuple, anyway.
> >
> > The fallback implementation is totally bogus, too.  Maximum of 1024
> > filters?  Erm, sfc can handle more than that.  And doing complex string
> > formatting in the kernel, even though all the parsing is in ethtool?
> >
> > Please, let's write off ETHTOOL_GRXNTUPLE as a failed experiment and
> > replace it with a command that behaves more like ETHTOOL_GRXCLSRLALL.
> >
> > Ben.
> 
> In order to address several different issues in the perfect filters 
> provided by 82599 I found it necessary to implement get_rx_ntuple so 
> that the driver could maintain the filter list inside of the driver 
> instead of having it maintained by the stack.  In doing so though I 
> found the bug.
> 
> I agree the fallback implementation has a limitation on the number and 
> format of filters it supports.  However declaring the function a "failed 
> experiment" and just dropping it isn't exactly constructive since we 
> have customers that are making use of the feature.
[...]

We can at least drop that fallback implementation since it apparently
doesn't work properly for either of the drivers that currently use it.

In the medium term, I do want to replace it with a binary interface and
move that formatting to ethtool.  ETHTOOL_GRXNTUPLE could be kept around
for a while for ixgbe only, while your customers have a chance to get
the updated ethtool.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


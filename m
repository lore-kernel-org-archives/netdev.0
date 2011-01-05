From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: update get_rx_ntuple to correctly
 interpret string count
Date: Tue, 04 Jan 2011 17:06:43 -0800
Message-ID: <4D23C423.3050609@intel.com>
References: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com> <1294185662.3636.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17253 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab1AEBGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 20:06:44 -0500
In-Reply-To: <1294185662.3636.61.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/4/2011 4:01 PM, Ben Hutchings wrote:
> On Tue, 2011-01-04 at 15:29 -0800, Alexander Duyck wrote:
>> Currently any strings returned via the get_rx_ntuple call will just be
>> dropped because the num_strings will be zero.  In order to correct this I
>> am updating things so that the return value of get_rx_ntuple is the number
>> of strings that were written, or a negative value if there was an error.
> [...]
>
> Nothing implements ethtool_ops::get_rx_ntuple, anyway.
>
> The fallback implementation is totally bogus, too.  Maximum of 1024
> filters?  Erm, sfc can handle more than that.  And doing complex string
> formatting in the kernel, even though all the parsing is in ethtool?
>
> Please, let's write off ETHTOOL_GRXNTUPLE as a failed experiment and
> replace it with a command that behaves more like ETHTOOL_GRXCLSRLALL.
>
> Ben.

In order to address several different issues in the perfect filters 
provided by 82599 I found it necessary to implement get_rx_ntuple so 
that the driver could maintain the filter list inside of the driver 
instead of having it maintained by the stack.  In doing so though I 
found the bug.

I agree the fallback implementation has a limitation on the number and 
format of filters it supports.  However declaring the function a "failed 
experiment" and just dropping it isn't exactly constructive since we 
have customers that are making use of the feature.  The fallback 
implementation is meant to be just that, and the patch I provided makes 
it possible to support more filters if needed by implementing a means of 
tracking/displaying the filters within the driver itself.

Thanks,

Alex

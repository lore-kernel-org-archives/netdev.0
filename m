From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH] ethtool: update get_rx_ntuple to correctly
 interpret string count
Date: Wed, 05 Jan 2011 08:57:01 -0800
Message-ID: <4D24A2DD.2040603@intel.com>
References: <20110104232947.3451.91153.stgit@gitlad.jf.intel.com>	 <1294185662.3636.61.camel@bwh-desktop>  <4D23C423.3050609@intel.com> <1294241216.15866.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4825 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab1AEQ5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 11:57:03 -0500
In-Reply-To: <1294241216.15866.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/5/2011 7:26 AM, Ben Hutchings wrote:
> On Tue, 2011-01-04 at 17:06 -0800, Alexander Duyck wrote:
>> On 1/4/2011 4:01 PM, Ben Hutchings wrote:
>>> On Tue, 2011-01-04 at 15:29 -0800, Alexander Duyck wrote:
>>>> Currently any strings returned via the get_rx_ntuple call will just be
>>>> dropped because the num_strings will be zero.  In order to correct this I
>>>> am updating things so that the return value of get_rx_ntuple is the number
>>>> of strings that were written, or a negative value if there was an error.
>>> [...]
>>>
>>> Nothing implements ethtool_ops::get_rx_ntuple, anyway.
>>>
>>> The fallback implementation is totally bogus, too.  Maximum of 1024
>>> filters?  Erm, sfc can handle more than that.  And doing complex string
>>> formatting in the kernel, even though all the parsing is in ethtool?
>>>
>>> Please, let's write off ETHTOOL_GRXNTUPLE as a failed experiment and
>>> replace it with a command that behaves more like ETHTOOL_GRXCLSRLALL.
>>>
>>> Ben.
>>
>> In order to address several different issues in the perfect filters
>> provided by 82599 I found it necessary to implement get_rx_ntuple so
>> that the driver could maintain the filter list inside of the driver
>> instead of having it maintained by the stack.  In doing so though I
>> found the bug.
>>
>> I agree the fallback implementation has a limitation on the number and
>> format of filters it supports.  However declaring the function a "failed
>> experiment" and just dropping it isn't exactly constructive since we
>> have customers that are making use of the feature.
> [...]
>
> We can at least drop that fallback implementation since it apparently
> doesn't work properly for either of the drivers that currently use it.
>
> In the medium term, I do want to replace it with a binary interface and
> move that formatting to ethtool.  ETHTOOL_GRXNTUPLE could be kept around
> for a while for ixgbe only, while your customers have a chance to get
> the updated ethtool.
>
> Ben.
>

I'm fine with us replacing the ETHTOOL_GRXNTUPLE interface, but I would 
prefer to do it after the merge windows for 2.6.39 has opened.  For now 
I would like to get this patch accepted as my main concern is getting a 
minor fix in versus rewriting the entire interface.

While we're at it how would you feel about us inverting the masks for 
setting up an ntuple by making them an inclusion mask instead of an 
exclusion one?  The reason why I ask is because I have to perform an and 
operation over all the input anyway before I can use it to compute the 
hashes and as such I am having to invert almost all of the mask bits, 
and it appears you are having to do this as well for many of the masks 
in sfc.

Thanks,

Alex

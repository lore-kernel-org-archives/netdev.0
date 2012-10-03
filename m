From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
 dependency.
Date: Tue, 02 Oct 2012 22:22:38 -0400 (EDT)
Message-ID: <20121002.222238.1580734803370802133.davem@davemloft.net>
References: <506546A7.7030500@linux.intel.com>
	<20120928.024621.1635385815700269914.davem@davemloft.net>
	<50654A62.5090003@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com,
	linux-kernel@vger.kernel.org, haicheng.lee@gmail.com
To: haicheng.li@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab2JCCXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:23:55 -0400
In-Reply-To: <50654A62.5090003@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Fri, 28 Sep 2012 14:57:38 +0800

> On 09/28/2012 02:46 PM, David Miller wrote:
>> From: Haicheng Li<haicheng.li@linux.intel.com>
>> Date: Fri, 28 Sep 2012 14:41:43 +0800
>>
>>> On 09/28/2012 06:09 AM, David Miller wrote:
>>>> Look at how other people submit patches, do any other patch
>>>> submissions
>>>> look like your's having all of this metadata in the message body:
>>> I'm sorry for it.
>>>
>>>> As for this specific patch:
>>>>
>>>>> -	depends on PTP_1588_CLOCK_PCH
>>>>> +	depends on PTP_1588_CLOCK_PCH = PCH_GBE
>>>>
>>>> This is not the correct way to ensure that the module'ness of one
>>>> config option meets the module'ness requirements of another.
>>>> The correct way is to say something like "&&   (PCH_GBE || PCH_GBE=n)"
>>>
>>> This case is a little bit tricky than usual, with PCH_PTP selected,
>>> the valid config would be either "PTP_1588_CLOCK_PCH=PCH_GBE=m" or
>>> "PTP_1588_CLOCK_PCH=PCH_GBE=y", and PTP_1588_CLOCK_PCH depends on
>>> PCH_GBE.
>>
>> And a simple "&&  PCH_GBE" should accomplish this, no?
> No sir. it's actually same with the original Kconfig (by a if
> PCH_GBE"), it just failed with this config:
> 
>         CONFIG_PCH_GBE=y
>         CONFIG_PCH_PTP=y
>         CONFIG_PTP_1588_CLOCK=m

The correct fix is to make the Kconfig entry for PCH_PTP use
a "select PTP_1588_CLOCK" instead of "depends PTP_1588_CLOCK"

I'll apply this fix.

The is another, extremely convoluted, way to do this, which is
what the SFC driver does which is:

depends on SFC && PTP_1588_CLOCK && !(SFC=y && PTP_1588_CLOCK=m)

but that looks horrible to me.

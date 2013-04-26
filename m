From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [IPROUTE PATCH] iproute2: act_ipt fix xtables breakage on older
 versions.
Date: Fri, 26 Apr 2013 08:58:20 -0700
Message-ID: <517AA41C.4040205@intel.com>
References: <20130425220716.6520.94862.stgit@ahduyck-cp1.jf.intel.com> <517A7F29.7070903@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33150 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab3DZP6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 11:58:45 -0400
In-Reply-To: <517A7F29.7070903@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2013 06:20 AM, Jamal Hadi Salim wrote:
> On 13-04-25 06:07 PM, Alexander Duyck wrote:
>> In trying to build on a RHEL6.3 I ran into several build issues that are
>> addressed in this patch.
>>
>> The first is that xtables_options_xfrm only has 3 options.  It
>> appears this is
>> how this code was originally.  As such for the case where the version
>> is less
>> than 6 I am assuming it would be correct to maintain the original
>> setup that
>> only had 3 parameters being passed instead of 4.
>>
>
>
> Getting it to compile is insufficient get it to work.
> We've gone over the specific issues you are running into and infact
> patches exist for both iproute2 and the kernel. I'll see if i can get
> something out this weekend.
> Hasan, you never got back to me on our last email exchange whether the
> proposed changes worked out. Can you please provide me some feedback?
>
> cheers,
> jamal

Getting it to compile is kind of important since it was preventing me
from completing the build for iproute2 as I had another fix I needed to
test.

If you have some test case you want me to run just let me know.  All I
did here is revert the changes that I believe were made incorrectly for
versions prior to 1.4.10 in "iproute2: act_ipt fix xtables breakage". 
It states it was fixing it for versions starting in 1.4.10 which I am
assuming is the XTABLES_VERSION_CODE >= 6 case so it should not have
modified the 3 parameter case for versions prior to 6 which is what I
corrected.

Thanks,

Alex

From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 28/29] fm10k: Add support for ptp to hw specific
 files
Date: Fri, 19 Sep 2014 08:34:46 -0700
Message-ID: <541C4D16.9050603@intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com> <20140918224023.10373.11456.stgit@ahduyck-bv4.jf.intel.com> <20140919073820.GA5954@netboy> <541C3F88.2090004@intel.com> <20140919151926.GA542@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51862 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932225AbaISPfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 11:35:23 -0400
In-Reply-To: <20140919151926.GA542@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 08:19 AM, Richard Cochran wrote:
> On Fri, Sep 19, 2014 at 07:36:56AM -0700, Alexander Duyck wrote:
>> On 09/19/2014 12:38 AM, Richard Cochran wrote:
>>> On Thu, Sep 18, 2014 at 06:40:30PM -0400, Alexander Duyck wrote:
>>>
>>>> +static s32 fm10k_adjust_systime_pf(struct fm10k_hw *hw, s32 ppb)
>>>> +{
>>>> +	u64 systime_adjust;
>>>> +
>>>> +	/* if sw_addr is not set we don't have switch register access */
>>>> +	if (!hw->sw_addr)
>>>> +		return ppb ? FM10K_ERR_PARAM : 0;
>>>> +
>>>> +	/* we must convert the value from parts per billion to parts per
>>>> +	 * 2^48 cycles.  In addition we can only use the upper 30 bits of
>>>> +	 * the value when making the change so that restricts us futher.
>>>> +	 * The math for this is equivilent to ABS(pps) * 2^40 / 10 ^ 9,
> 
> ...
> 
>> 2.  The value is in 2 ^ 48 units, and the OS wants to give us a value in
>> parts per billion, not parts per 256 * 2 ^ 40.  So in order to simplify
>> things I dropped the lower 8 bits and only update
> 
> So what does the comment in the code about "upper 30 bits" mean?
> 

The value is measured in parts per 2^48 units, but the field we are
given to provide adjustment units is 38 bits wide, with the 30 most
significant bits in the main adjustment register, and the 8 least
significant bits in another register.  The direction is a separate bit
at bit 31 in the upper register with a 1 bit gap between it and the value.

Thanks,

Alex

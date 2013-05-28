From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [E1000-devel] [PATCH net-next 4/4] igb: enable auxiliary PHC
 functions for the i210.
Date: Tue, 28 May 2013 10:39:58 -0700
Message-ID: <51A4EBEE.90000@intel.com>
References: <cfbb4fdcf968d81b2211b97c75c9b5bf820570e4.1369645944.git.richardcochran@gmail.com> <CDCA1F64.1E87D%matthew.vick@intel.com> <20130528162325.GD4678@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57552 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964784Ab3E1Rj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 13:39:59 -0400
In-Reply-To: <20130528162325.GD4678@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2013 09:23 AM, Richard Cochran wrote:
> On Tue, May 28, 2013 at 03:58:07PM +0000, Vick, Matthew wrote:
>> On 5/27/13 2:21 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:
>  
>> I would prefer it if we did a MAC check before these two TSICR checks,
>> since we're making some assumptions about the hardware within the
>> interrupt cases. At the very least, a comment that these are only
>> applicable to I210/I211 would be nice.
> I can respin with a comment that the additional bits are i210 only. I
> think this is better than adding more checks into ISR. Since we only
> enable these bits for the i210, the checks would be redundant.
>
>>> diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c
>>> b/drivers/net/ethernet/intel/igb/igb_ptp.c
>>> index 5944de0..8cf4b8a 100644
>>> --- a/drivers/net/ethernet/intel/igb/igb_ptp.c
>>> +++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
>>> @@ -23,6 +23,15 @@
>>>
>>> #include "igb.h"
>>>
>>> +static int igb_input_sdp = 0;
>>> +static int igb_output_sdp = 1;
>>> +module_param(igb_input_sdp, int, 0444);
>>> +module_param(igb_output_sdp, int, 0444);
>>> +MODULE_PARM_DESC(igb_input_sdp,
>>> +		 "The SDP used as an input, to time stamp external events");
>>> +MODULE_PARM_DESC(igb_output_sdp,
>>> +		 "The SDP used to output the programmable periodic signal");
>>> +
>> Is there any other mechanism we could use to control this? I would imagine
>> not, but I know module parameters are generally frowned upon.
> This the way I handled it for the PHYTER, and I think it is the best
> way from our three choices:
>
> 1. kconfig option (inflexible)
> 2. module param
> 3. ethtool (can o'worms)

I really think the ethtool approach would be preferred since it is the
most flexible.  The problem with module parameters is that it only
really works with one port.

Couldn't you use the ethtool private flags interface or something
similar to achieve the same result?

Thanks,

Alex

From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 10:33:44 -0700
Message-ID: <4DC18DF8.3090707@chelsio.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21954 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab1EDRdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:33:53 -0400
In-Reply-To: <1304529892.2926.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2011 10:24 AM, Ben Hutchings wrote:
> On Wed, 2011-05-04 at 10:09 -0700, Dimitris Michailidis wrote:
>> On 05/03/2011 04:34 PM, Ben Hutchings wrote:
>>> On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
>>>> I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is 
>>>> enough knowledge to pick an appropriate slot.  So I'd remove the
>>>>
>>>>      if (loc == RX_CLS_LOC_UNSPEC)
>>>>
>>>> block above, let the driver pick a slot, and then pass the selected location 
>>>> back for ethtool to report.
>>> But first we have to specify this in the ethtool API.  So please propose
>>> a patch to ethtool.h.
>> In the past we discussed that being able to specify the first available slot or 
>> the last available would be useful, so something like the below?
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index 4194a20..909ef79 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -442,7 +442,8 @@ struct ethtool_flow_ext {
>>    *	includes the %FLOW_EXT flag.
>>    * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
>>    *	if packets should be discarded
>> - * @location: Index of filter in hardware table
>> + * @location: Index of filter in hardware table, or %RX_CLS_FLOW_FIRST_LOC for
>> + *	first available index, or %RX_CLS_FLOW_LAST_LOC for last available
> [...]
> 
> I think that's reasonable.  We should also explicitly state that
> location determines priority, i.e. if a packet matches two filters then
> the one with the lower location wins.

Easy and true for a TCAM.  For hashing would you use the location to decide how 
to order filters that fall in the same bucket?


From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/7] net: rtnetlink: allow only one idx saving
 stats attribute
Date: Thu, 28 Apr 2016 10:40:40 +0200
Message-ID: <5721CC88.9000708@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
 <1461773902-13528-3-git-send-email-nikolay@cumulusnetworks.com>
 <57219D29.2080307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37230 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbcD1Iko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 04:40:44 -0400
Received: by mail-wm0-f43.google.com with SMTP id a17so52689972wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 01:40:44 -0700 (PDT)
In-Reply-To: <57219D29.2080307@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2016 07:18 AM, Roopa Prabhu wrote:
> On 4/27/16, 9:18 AM, Nikolay Aleksandrov wrote:
>> We can't allow more than one stats attribute which uses the local idx
>> since the result will be a mess. This is a simple check to make sure
>> only one is being used at a time. Later when the filter_mask's 32 bits
>> are over we can switch to a bitmap.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>>  include/net/rtnetlink.h |  6 ++++++
>>  net/core/rtnetlink.c    | 17 +++++++++++++++--
>>  2 files changed, 21 insertions(+), 2 deletions(-)
>>
[snip]
>> @@ -3570,6 +3578,11 @@ static int rtnl_stats_dump(struct sk_buff *skb, struct netlink_callback *cb)
>>  	if (!filter_mask)
>>  		return -EINVAL;
>>  
>> +	/* only one attribute which can save a local idx is allowed at a time */
>> +	lidx_filter = filter_mask & IFLA_STATS_IDX_ATTR_MASK;
>> +	if (lidx_filter && !is_power_of_2(lidx_filter))
>> +		return -EINVAL;
>> +
>>  	
> instead of introducing the restriction at this level, is it possible to use two args for this
> like below and avoid the restriction ?
> cb->args[2] = current filter being processed
> cb->args[3] = private filter idx (your lidx)
> 

So to allow having any number of idx saving callbacks ? I think this will introduce more complexity
as we'll have to differentiate between 3 types of filters now - non-idx saving, idx saving but passed
and current idx saving attribute. We will dump the non-idx saving on each call, but then skip some
and continue dumping..
I'll give it a try to see how it looks. :-)

Thanks,
 Nik

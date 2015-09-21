From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Mon, 21 Sep 2015 14:58:00 -0700 (PDT)
Message-ID: <20150921.145800.1946648892912159723.davem@davemloft.net>
References: <1442859588-14831-1-git-send-email-dsa@cumulusnetworks.com>
	<20150921141929.681ebf69@urahara>
	<56007695.3070003@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbbIUV6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 17:58:03 -0400
In-Reply-To: <56007695.3070003@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 21 Sep 2015 15:28:53 -0600

> On 9/21/15 3:19 PM, Stephen Hemminger wrote:
>>> @@ -1638,6 +1638,8 @@ static int iproute_get(int argc, char **argv)
>>>   	if (req.r.rtm_family == AF_UNSPEC)
>>>   		req.r.rtm_family = AF_INET;
>>>
>>> +	req.r.rtm_flags |= RTM_F_LOOKUP_TABLE;
>>> +
>>>   	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
>>>   		exit(2);
>>>
>>
>> How will this work (or not) on older kernels?
>>
> 
> It works just fine. First test used the wrong VM and was puzzled to
> not see the table id in the output. Then I realized the older kernel
> did not recognize the RTM_F_LOOKUP_TABLE; silently ignores the
> flag. With a kernel that does recognize it I get the table id in the
> output when it is not main.

I think if it always gave MAIN in older kernels, iproute should continue
to do so.

You can't just remove the table ID output just because you disagree with
the semantics given by old kernels.

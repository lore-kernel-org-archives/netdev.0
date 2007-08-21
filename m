From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4 - rev2] Add new timeval_to_sec function
Date: Tue, 21 Aug 2007 09:09:33 +0530
Message-ID: <46CA5E75.9050904@linux.vnet.ibm.com>
References: <20070820134536.d260585a.varunc@linux.vnet.ibm.com> <20070820075325.43bd8f60@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, krkumar2@in.ibm.com, varuncha@in.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56086 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbXHUDjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 23:39:05 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l7L2W4gl016761
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 22:32:04 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7L3cwUO251216
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 21:38:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7L3cvhH010889
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 21:38:58 -0600
In-Reply-To: <20070820075325.43bd8f60@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 20 Aug 2007 13:45:36 +0530
> Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:
>
>   
>> A new function for converting timeval to time_t is added in time.h. Its a common function used in different
>> places.
>>
>> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
>> ---
>>  include/linux/time.h |   12 ++++++++++++
>>  1 files changed, 12 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/time.h b/include/linux/time.h
>> index 6a5f503..1faf65c 100644
>> --- a/include/linux/time.h
>> +++ b/include/linux/time.h
>> @@ -149,6 +149,18 @@ static inline s64 timeval_to_ns(const st
>>  }
>>  
>>  /**
>> + * timeval_to_sec - Convert timeval to seconds
>> + * @tv:         pointer to the timeval variable to be converted
>> + *
>> + * Returns the seconds representation of timeval parameter.
>> + * Note : Here we round up the value. We dont need accuracy.
>> + */
>> +static inline time_t timeval_to_sec(const struct timeval *tv)
>> +{
>> +	return (tv->tv_sec + (tv->tv_usec ? 1 : 0));
>> +}
>> +
>>     
>
> Why roundup? Unless there is a requirement in the standard, please just
> use the timeval seconds. In which case the inline is unneeded.
>
>
>   
Thanks for the reply stephen. As you might be aware that this discussion
took place sometime ago when i posted my first patch set.
Initially it was like this:

return (tv->tv_sec + (tv->tv_usec + 500000)/1000000);
Then i got some comments from patrick and oliver. They wanted me to
round it up.

So what about rounding up with

return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);


Then on second revision the above was changed to

return tv->tv_sec + (tv->tv_usec ? 1 : 0);

as it would be much faster. Since the timeval is meant for stats purpose
we decided not really bother about accuracy. My initial patch actually
took only sec value into account, but i was adviced to round up usec to
give a better o/p. Is that ok??? Or you still think we should consider
only secs?

Regards,
Varun

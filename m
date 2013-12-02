From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: make the max_burst min value to 1
Date: Mon, 02 Dec 2013 09:51:43 -0500
Message-ID: <529C9E7F.7040707@gmail.com>
References: <529C2E01.3090005@huawei.com> <20131202115640.GA10857@hmsreliant.think-freely.org> <529C7707.5020908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, dingtianhong@huawei.com
To: Wang Weidong <wangweidong1@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:48291 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab3LBOvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 09:51:46 -0500
In-Reply-To: <529C7707.5020908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2013 07:03 AM, Wang Weidong wrote:
> On 2013/12/2 19:56, Neil Horman wrote:
>> On Mon, Dec 02, 2013 at 02:51:45PM +0800, Wang Weidong wrote:
>>> From: Wang Weidong <wangweidong1@huawei.com>
>>>
>>> when I setted the max_burst to 0, do the lksctp-tools I got hang.
>>> I found sctp_transport_burst_limited would make the cwnd to 0.
>>> so I make the max_burst min value to 1.
>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>> ---
>>>  net/sctp/sysctl.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>>> index 7637e8e..46832d3 100644
>>> --- a/net/sctp/sysctl.c
>>> +++ b/net/sctp/sysctl.c
>>> @@ -135,7 +135,7 @@ static struct ctl_table sctp_net_table[] = {
>>>  		.maxlen		= sizeof(int),
>>>  		.mode		= 0644,
>>>  		.proc_handler	= proc_dointvec_minmax,
>>> -		.extra1		= &zero,
>>> +		.extra1		= &one,
>>>  		.extra2		= &int_max
>>>  	},
>>>  	{
>>> -- 
>>> 1.7.12
>>>
>>>
>>
>>
>> This seems like a band-aid to me.  There are a few things wrong:
>>
>> 1) You can also set the the max_burst via setsockopt, and so this would need to
>> be checked in that path as well.
>>
>> 2) I don't see how having a cwnd of zero would cause a hang.  It looks like a
>> cwnd of zero would perpetually place the association in a slow start state,
>> which is silly but not illegal.  
>>
> 
> Hm, Good suggestions. Ok, I will try it again and find the root cause.
> Thanks!

It's really simple.  sctp_transport_burst_limited() should simply do
nothing if max_burst is 0, essentially allowing unlimited bursts.

-vlad

> 
>> Please investigate the acutally root cause of the problem before just avoiding
>> it like this.
>>
>> Thanks!
>> Neil
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
> 
> 

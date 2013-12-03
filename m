From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH] sctp: make the max_burst min value to 1
Date: Tue, 3 Dec 2013 09:35:00 +0800
Message-ID: <529D3544.7030009@huawei.com>
References: <529C2E01.3090005@huawei.com> <20131202115640.GA10857@hmsreliant.think-freely.org> <529C7707.5020908@huawei.com> <529C9E7F.7040707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<dingtianhong@huawei.com>, David Miller <davem@davemloft.net>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	<Michael.Tuexen@lurchi.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:6917 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab3LCBhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 20:37:55 -0500
In-Reply-To: <529C9E7F.7040707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/2 22:51, Vlad Yasevich wrote:
> On 12/02/2013 07:03 AM, Wang Weidong wrote:
>> On 2013/12/2 19:56, Neil Horman wrote:
>>> On Mon, Dec 02, 2013 at 02:51:45PM +0800, Wang Weidong wrote:
>>>> From: Wang Weidong <wangweidong1@huawei.com>
>>>>
>>>> when I setted the max_burst to 0, do the lksctp-tools I got hang.
>>>> I found sctp_transport_burst_limited would make the cwnd to 0.
>>>> so I make the max_burst min value to 1.
>>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>>> ---
>>>>  net/sctp/sysctl.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>>>> index 7637e8e..46832d3 100644
>>>> --- a/net/sctp/sysctl.c
>>>> +++ b/net/sctp/sysctl.c
>>>> @@ -135,7 +135,7 @@ static struct ctl_table sctp_net_table[] = {
>>>>  		.maxlen		= sizeof(int),
>>>>  		.mode		= 0644,
>>>>  		.proc_handler	= proc_dointvec_minmax,
>>>> -		.extra1		= &zero,
>>>> +		.extra1		= &one,
>>>>  		.extra2		= &int_max
>>>>  	},
>>>>  	{
>>>> -- 
>>>> 1.7.12
>>>>
>>>>
>>>
>>>
>>> This seems like a band-aid to me.  There are a few things wrong:
>>>
>>> 1) You can also set the the max_burst via setsockopt, and so this would need to
>>> be checked in that path as well.
>>>
>>> 2) I don't see how having a cwnd of zero would cause a hang.  It looks like a
>>> cwnd of zero would perpetually place the association in a slow start state,
>>> which is silly but not illegal.  
>>>
>>
>> Hm, Good suggestions. Ok, I will try it again and find the root cause.
>> Thanks!
> 
> It's really simple.  sctp_transport_burst_limited() should simply do
> nothing if max_burst is 0, essentially allowing unlimited bursts.
> 
> -vlad
> 

I will add the a check of max_burst, if max_burst is 0, just do nothing. Michael
point out that it just disable max_burst which declared in rfc6458#section-8.1.24
as well.

Thanks.

>>
>>> Please investigate the acutally root cause of the problem before just avoiding
>>> it like this.
>>>
>>> Thanks!
>>> Neil
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>>
>>
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

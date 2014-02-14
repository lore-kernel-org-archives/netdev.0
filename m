From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v3 2/2] sctp: optimize the sctp_sysctl_net_register
Date: Fri, 14 Feb 2014 10:18:05 +0800
Message-ID: <52FD7CDD.1010206@huawei.com>
References: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com> <1392169484-8256-3-git-send-email-wangweidong1@huawei.com> <20140212115344.GB4038@hmsreliant.think-freely.org> <52FC1D9D.3090500@huawei.com> <20140213124434.GA27319@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<dborkman@redhat.com>, <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25701 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaBNCSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 21:18:45 -0500
In-Reply-To: <20140213124434.GA27319@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/13 20:44, Neil Horman wrote:
> On Thu, Feb 13, 2014 at 09:19:25AM +0800, Wang Weidong wrote:
>> On 2014/2/12 19:53, Neil Horman wrote:
>>> On Wed, Feb 12, 2014 at 09:44:44AM +0800, Wang Weidong wrote:
>>>> Here, when the net is init_net, we needn't to kmemdup the ctl_table
>>>> again. So add a check for net. Also we can save some memory.
>>>>
>>>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>>>> ---
>>>>  net/sctp/sysctl.c | 17 ++++++++++-------
>>>>  1 file changed, 10 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>>>> index d354de5..35c8923 100644
>>>> --- a/net/sctp/sysctl.c
>>>> +++ b/net/sctp/sysctl.c
>>>> @@ -402,15 +402,18 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>>>>  
>>>>  int sctp_sysctl_net_register(struct net *net)
>>>>  {
>>>> -	struct ctl_table *table;
>>>> -	int i;
>>>> +	struct ctl_table *table = sctp_net_table;
>>>> +
>>>> +	if (!net_eq(net, &init_net)) {
>>>> +		int i;
>>>>  
>>>> -	table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
>>>> -	if (!table)
>>>> -		return -ENOMEM;
>>>> +		table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
>>>> +		if (!table)
>>>> +			return -ENOMEM;
>>>>  
>>>> -	for (i = 0; table[i].data; i++)
>>>> -		table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
>>>> +		for (i = 0; table[i].data; i++)
>>>> +			table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
>>>> +	}
>>>>  
>>> In the first version of this patch you complained about a lockdep issue.  Did
>>> you figure out what that was, and if it related to these changes?
>>>
>>> Neil
>>>
>>>
>> Hi Neil,
>>
>> The lockdep issue doesn't relate to these changes. I should send it
>> by the another email. Sorry for confusing you.
>>
>> Regards
>> Wang
>>
> Then you probably don't need to mention it in the same note that you're
> proposing changes.
> 
Ok. Got it!

Thanks
Wang

> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
> .
> 

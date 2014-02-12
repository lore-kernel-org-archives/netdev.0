From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH v2 2/2] sctp: optimize the sctp_sysctl_net_register
Date: Wed, 12 Feb 2014 09:21:05 +0800
Message-ID: <52FACC81.2090405@huawei.com>
References: <1392083346-9420-1-git-send-email-wangweidong1@huawei.com> <1392083346-9420-3-git-send-email-wangweidong1@huawei.com> <52FA5418.6090007@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:37978 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbaBLBXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:23:03 -0500
In-Reply-To: <52FA5418.6090007@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/12 0:47, Sergei Shtylyov wrote:
> Hello.
> 
> On 02/11/2014 04:49 AM, Wang Weidong wrote:
> 
>> Here, when the net is init_net, we needn't to kmemdup the ctl_table
>> again. So add a check for net. Also we can save some memory.
> 
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>>   net/sctp/sysctl.c | 16 +++++++++-------
>>   1 file changed, 9 insertions(+), 7 deletions(-)
> 
>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>> index 2ddb401..b65396b 100644
>> --- a/net/sctp/sysctl.c
>> +++ b/net/sctp/sysctl.c
>> @@ -403,15 +403,17 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>>
>>   int sctp_sysctl_net_register(struct net *net)
>>   {
>> -    struct ctl_table *table;
>> -    int i;
>> +    struct ctl_table *table = sctp_net_table;
>>
>> -    table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
>> -    if (!table)
>> -        return -ENOMEM;
>> +    if (!net_eq(net, &init_net)) {
>> +        int i;
> 
>    Empty line after declaration wouldn't hurt, just like above.
> 
Yeah. I will change it soon.

Thanks
Wang

>> +        table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
>> +        if (!table)
>> +            return -ENOMEM;
> 
> WBR, Sergei
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

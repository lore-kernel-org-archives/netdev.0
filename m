From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH 0/2] sctp: fix a problem with net_namespace
Date: Mon, 27 Jan 2014 21:05:02 +0800
Message-ID: <52E6597E.8040608@gmail.com>
References: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com> <20140127114904.GA17143@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vyasevich@gmail.com, dborkman@redhat.com,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:59802 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaA0NKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 08:10:25 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so5911088pab.9
        for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 05:10:24 -0800 (PST)
In-Reply-To: <20140127114904.GA17143@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>

On 2014/1/27 19:49, Neil Horman wrote:
> On Mon, Jan 27, 2014 at 11:49:01AM +0800, Wang Weidong wrote:
>> fix a problem with net_namespace, and optimize
>> the sctp_sysctl_net_register.
>>
>> Wang Weidong (2):
>>    sctp: fix a missed .data initialization
>>    sctp: optimize the sctp_sysctl_net_register
>>
>>   net/sctp/sysctl.c | 17 ++++++++++-------
>>   1 file changed, 10 insertions(+), 7 deletions(-)
>>
>> --
>> 1.7.12
>>
>>
>>
> I don't see that either of these patches are needed.  In sctp_init_net, the
> sctp_hmac_alg pointer gets initalized before calling sctp_sysctl_net_register,
> and sctp_proc_do_hmac_alg is written to specifically expect NULL values, so this
> code may change behavior regarding default cookie selection.
>
> This was coded so that poniters to entires in the string table could be used,
> rather than needing to allocate or maintain character buffers.  That said, it
> does look like that for loop in sctp_sysctl_register_table might compute an odd
> offset when cloning the table.  I think the right fix for that is likely to just
> move the sysctl value initalization in sctp_init_net to below the sysctl
> register function.
>
> Neil
>

Thanks Neil,
I will try to refix it as you said tomorrow because I am not at the office.

Regards,
Wang

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

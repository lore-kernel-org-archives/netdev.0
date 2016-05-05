From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: vrf: Create FIB tables on link create
Date: Wed, 4 May 2016 22:29:36 -0600
Message-ID: <572ACC30.8080604@cumulusnetworks.com>
References: <1462421887-10712-1-git-send-email-dsa@cumulusnetworks.com>
 <20160505.002448.1005276153595006235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34148 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbcEEE3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 00:29:41 -0400
Received: by mail-ob0-f182.google.com with SMTP id dm5so31151811obc.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 21:29:41 -0700 (PDT)
In-Reply-To: <20160505.002448.1005276153595006235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/16 10:24 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed,  4 May 2016 21:18:07 -0700
>
>> @@ -372,9 +372,13 @@ static int vrf_rt6_create(struct net_device *dev)
>>   	if (!rt6)
>>   		goto out;
>>
>> -	rt6->dst.output	= vrf_output6;
>> -	rt6->rt6i_table = fib6_get_table(net, vrf->tb_id);
>>   	dst_hold(&rt6->dst);
>> +
>> +	rt6->rt6i_table = fib6_new_table(net, vrf->tb_id);
>> +	if (!rt6->rt6i_table)
>> +		goto out;
>> +
>> +	rt6->dst.output	= vrf_output6;
>>   	vrf->rt6 = rt6;
>>   	rc = 0;
>>   out:
>
> This leaks rt6.
>

Indeed. That fact was lost by follow on patches which fix the ordering.

From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: ipvlan: Initial check-in of the IPVLAN driver.
Date: Fri, 23 Jan 2015 14:40:44 -0800
Message-ID: <CAF2d9jgkrwkMKuSjhibZvjvG4fV=SadyU-1AnKNdD8EvHDd5qw@mail.gmail.com>
References: <20150119144011.GA19086@mwanda> <20150119.162059.2087370902498436539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dan.carpenter@oracle.com, linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36645 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbAWWlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 17:41:05 -0500
Received: by mail-ob0-f173.google.com with SMTP id vb8so77685obc.4
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 14:41:05 -0800 (PST)
In-Reply-To: <20150119.162059.2087370902498436539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 1:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Mon, 19 Jan 2015 17:40:11 +0300
>
>> The patch 2ad7bf363841: "ipvlan: Initial check-in of the IPVLAN
>> driver." from Nov 23, 2014, leads to the following static checker
>> warning:
>>
>>       drivers/net/ipvlan/ipvlan_core.c:380 ipvlan_process_v6_outbound()
>>       warn: 'dst' isn't an ERR_PTR
>>
>> drivers/net/ipvlan/ipvlan_core.c
>>    378
>>    379          dst = ip6_route_output(dev_net(dev), NULL, &fl6);
>>    380          if (IS_ERR(dst))
>>    381                  goto err;
>>
>> The ip6_route_output() function is not documented but it always returns
>> a valid pointer.  I believe you are supposed to check something like:
>>
>>               if (dst->error) {
>>                       ret = dst->error;
>>                       goto error;
>>               }
>>
>>    382
>>    383          skb_dst_drop(skb);
>>    384          skb_dst_set(skb, dst);
>
> This is correct.

Thanks Dan for pointing it out. I'll send a patch correcting that code.

From: Roman Kapl <roman.kapl@sysgo.com>
Subject: Re: [PATCH] net: set default value for somaxconn
Date: Tue, 23 May 2017 14:26:53 +0200
Message-ID: <bcc6f761-9cc1-6a2c-8c8a-1006403d6822@sysgo.com>
References: <20170522122241.28389-1-roman.kapl@sysgo.com>
 <20170522.141809.2056075174395561778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sysgo.com ([176.9.12.79]:57282 "EHLO mail.sysgo.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763864AbdEWM0z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 08:26:55 -0400
In-Reply-To: <20170522.141809.2056075174395561778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 08:18 PM, David Miller wrote:
> From: Roman Kapl <roman.kapl@sysgo.com>
> Date: Mon, 22 May 2017 14:22:41 +0200
>
>> The default value for somaxconn is set in sysctl_core_net_init(), but this
>> function is not called when kernel is configured without CONFIG_SYSCTL.
>>
>> This results in the kernel not being able to accept TCP connections,
>> because the backlog has zero size. Usually, the user ends up with:
>> "TCP: request_sock_TCP: Possible SYN flooding on port 7. Dropping request.  Check SNMP counters."
>>
>> Before ef547f2ac16 (tcp: remove max_qlen_log), the effects were less
>> severe, because the backlog was always at least eight slots long.
>>
>> Signed-off-by: Roman Kapl <roman.kapl@sysgo.com>
> I see the problem, but this changes behavior.
>
> Existing code will set somaxconn to the default value for every namespace
> that is created.
>
> But with you changes, any modification made to init_net's value will
> get inherited by any namespace created as a child thereafterwards.
Hmm, I can not find where somaxconn is inherited. But I see this needs 
to be per-net.
>
> You really need to make this happen via pernet_operations, or even
> inside of setup_net().
I will create new pernet_operations in net_namespace.c, move the 
somaxconn initialization there and send a new patch.

Thanks for comments, Roman Kapl

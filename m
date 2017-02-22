From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Date: Wed, 22 Feb 2017 12:35:20 +0300
Message-ID: <ce0ad8f1-f0df-0853-92ce-7dbb22c94698@virtuozzo.com>
References: <CACT4Y+aZrpZ3JevLrg5i=nTzBAcVhKX9qmajyW5b-+xExwrCHg@mail.gmail.com>
 <20170221112740.661-1-aryabinin@virtuozzo.com>
 <20170221.132351.1602433391866901233.davem@davemloft.net>
 <20170221.132449.1868705782244690263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: <gerrit@erg.abdn.ac.uk>, <dccp@vger.kernel.org>,
        <dvyukov@google.com>, <edumazet@google.com>,
        <xiyou.wangcong@gmail.com>, <kuznet@ms2.inr.ac.ru>,
        <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <syzkaller@googlegroups.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0133.outbound.protection.outlook.com ([104.47.0.133]:4160
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932129AbdBVJeY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 04:34:24 -0500
In-Reply-To: <20170221.132449.1868705782244690263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2017 09:24 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 21 Feb 2017 13:23:51 -0500 (EST)
> 
>> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Date: Tue, 21 Feb 2017 14:27:40 +0300
>>
>>> DCCP doesn't purge timewait sockets on network namespace shutdown.
>>> So, after net namespace destroyed we could still have an active timer
>>> which will trigger use after free in tw_timer_handler():
>>  ...
>>> Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
>>> timewait sockets on net namespace destruction and prevent above issue.
>>>
>>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>>> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>
>> Applied and queued up for -stable, thanks.
> 
> Actually, this doesn't even compile.  Please fix this up and resubmit:
> 

Right, I tested this on top of the Linus' tree. Rebased on -next now.

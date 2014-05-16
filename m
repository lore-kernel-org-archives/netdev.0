From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net-gro: reset skb->truesize in napi_reuse_skb()
Date: Fri, 16 May 2014 14:27:00 -0700
Message-ID: <CAHA+R7MZEHhqLrxdcp-M3pWEC_wVkm5W5v8HUDSc_w10HYg5aQ@mail.gmail.com>
References: <1396542490.12330.17.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140403.161834.1232262926542795326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:38979 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468AbaEPV1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:27:02 -0400
Received: by mail-lb0-f169.google.com with SMTP id s7so2390946lbd.28
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 14:27:00 -0700 (PDT)
In-Reply-To: <20140403.161834.1232262926542795326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 3, 2014 at 1:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Apr 2014 09:28:10 -0700
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Recycling skb always had been very tough...
>>
>> This time it appears GRO layer can accumulate skb->truesize
>> adjustments made by drivers when they attach a fragment to skb.
>>
>> skb_gro_receive() can only subtract from skb->truesize the used part
>> of a fragment.
>>
>> I spotted this problem seeing TcpExtPruneCalled and
>> TcpExtTCPRcvCollapsed that were unexpected with a recent kernel, where
>> TCP receive window should be sized properly to accept traffic coming
>> from a driver not overshooting skb->truesize.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Nasty...
>
> Applied, thanks Eric.

I think this patch should be queued for -stable as well?
Looking at your stable queue [1], it's not there. :)

Thanks!

1. http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

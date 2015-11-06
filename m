From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net] selinux: fix random read in selinux_ip_postroute_compat()
Date: Fri, 6 Nov 2015 14:52:38 +0100
Message-ID: <CACT4Y+ZsiydE4BL_6pGS=LcmS19Dr0+HoJ19AY-4UNNxm3eNXA@mail.gmail.com>
References: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
 <1446752806.4184.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <1446759564.4184.65.camel@edumazet-glaptop2.roam.corp.google.com> <20151105.164613.618044250901993825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, Paul Moore <paul@paul-moore.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35985 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932918AbbKFNw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 08:52:59 -0500
Received: by wimw2 with SMTP id w2so30751651wim.1
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 05:52:58 -0800 (PST)
In-Reply-To: <20151105.164613.618044250901993825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 5, 2015 at 10:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 05 Nov 2015 13:39:24 -0800
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> In commit e446f9dfe17b ("net: synack packets can be attached to request
>> sockets"), I missed one remaining case of invalid skb->sk->sk_security
>> access.
>>
>> Dmitry Vyukov got a KASan report pointing to it.
>>
>> Add selinux_skb_sk() helper that is responsible to get back to the
>> listener if skb is attached to a request socket, instead of
>> duplicating the logic.
>>
>> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Paul Moore <paul@paul-moore.com>
>
> Looks good, applied, thanks Eric!

Fixed the issue for me.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 10:20:33 -0800
Message-ID: <CAM_iQpXd8qTTRT_+CkHnpMNC=CSS9vfB6zKtSjmLV_yya5BL8Q@mail.gmail.com>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170113000700.GA1482@electric-eye.fr.zoreil.com> <20170113.121001.2197905484527884236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35822 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdAMS3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:29:00 -0500
Received: by mail-qk0-f194.google.com with SMTP id u25so8215067qki.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 10:28:20 -0800 (PST)
In-Reply-To: <20170113.121001.2197905484527884236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 9:10 AM, David Miller <davem@davemloft.net> wrote:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Fri, 13 Jan 2017 01:07:00 +0100
>
>> Were alloc_skb moved one level up in the call stack, there would be
>> no need to use the new wait api in the subsequent page, thus easing
>> pre 3.19 longterm kernel maintenance (at least those on korg page).
>>
>> But it tastes a tad bit too masochistic.
>
> Lack of error handling of allocation failure is always a huge red
> flag.  We even long ago tried to do something like this for TCP FIN
> handling.
>
> It's dumb, it doesn't work.
>
> Therefore I agree that the correct fix is to move the SKB allocation
> up one level to vcc_sendmsg() and make it handle errors properly.

If you can justify API is not broken by doing that, I am more than happy
to do it, as I already stated in the latter patch:

"Of course, the logic itself is suspicious, other sendmsg()
could handle skb allocation failure very well, not sure
why ATM has to wait for a successful one here. But probably
it is too late to change since the errno and behavior is
visible to user-space. So just leave the logic as it is."

For some reason, no one reads that patch. :-/

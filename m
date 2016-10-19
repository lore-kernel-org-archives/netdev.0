From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: fix a potential deadlock in do_ipv6_setsockopt()
Date: Wed, 19 Oct 2016 16:41:44 -0700
Message-ID: <CAM_iQpXNbc1pphwfvUoFXE318pgVZdkvHWKG98kUyntUno3Cqw@mail.gmail.com>
References: <1476901218-15635-1-git-send-email-xiyou.wangcong@gmail.com> <1476920329.5650.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Baozeng Ding <sploving1@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34825 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753079AbcJSXmG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 19:42:06 -0400
Received: by mail-it0-f66.google.com with SMTP id 139so3249503itm.2
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:42:06 -0700 (PDT)
In-Reply-To: <1476920329.5650.77.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 4:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
>> index 46ad699..b8c8d20 100644
>> --- a/net/ipv6/af_inet6.c
>> +++ b/net/ipv6/af_inet6.c
>> @@ -414,7 +414,9 @@ int inet6_release(struct socket *sock)
>>               return -EINVAL;
>>
>>       /* Free mc lists */
>> +     rtnl_lock();
>
> Certainly not.
>
> Some people want IPv6 being reasonably fast.

Oh, good catch, I should move the 'if' check out too...

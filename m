From: Madhu Challa <challa@noironetworks.com>
Subject: Re: [PATCH] multicast: Extend ip address command to enable multicast
 group join/leave on IP level.
Date: Tue, 17 Feb 2015 11:06:44 -0800
Message-ID: <CAN_zqfP1RB+jtyR_Gg4cac6BAxnbYC1kAtY6MmOXRPwh+8te8Q@mail.gmail.com>
References: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
	<1424171410.4942.74.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAN_zqfOADJwrs=SfiKYfY9iGQh_jA3PrFHnRM1k=rTgUt6iqBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43054 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbbBQTGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 14:06:45 -0500
Received: by pdev10 with SMTP id v10so45631021pde.10
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 11:06:44 -0800 (PST)
In-Reply-To: <CAN_zqfOADJwrs=SfiKYfY9iGQh_jA3PrFHnRM1k=rTgUt6iqBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I realized we will have to do the same refactoring in ipv6 code as
well. I was also missing the mc_autojoin_sock initialization in ipv6
code that I just added. I will be happy to do the refactoring if you
want me to.

Thanks.

On Tue, Feb 17, 2015 at 8:08 AM, Madhu Challa <challa@noironetworks.com> wrote:
>
>
> On Tue, Feb 17, 2015 at 3:10 AM, Eric Dumazet <eric.dumazet@gmail.com>
> wrote:
>>
>> On Mon, 2015-02-16 at 14:20 -0800, Madhu Challa wrote:
>> > Joining multicast group on ethernet level via "ip maddr" command would
>> > not work if we have an Ethernet switch that does igmp snooping since
>> > the switch would not replicate multicast packets on ports that did not
>> > have IGMP reports for the multicast addresses.
>> >
>> ...
>> > +struct mc_autojoin_request {
>> > +     union {
>> > +             struct sockaddr_in sin;
>> > +             struct sockaddr_in6 sin6;
>> > +     } addr;
>> > +     int ifindex;
>> > +     struct sock *sk;
>> > +     struct work_struct ipv4_work;
>> > +     struct work_struct ipv6_work;
>> > +     bool join;
>> > +};
>>
>> This looks a net-next patch, right ?
>
>
> yes.
>>
>>
>> You do not need 2 separate work_struct. A single one is enough, or even
>> no work queue at all as a matter of fact.
>>
>> I'll send a preparation patch like this one, then you'll be able to call
>> __ip_mc_{join|leave}_group() directly while RTNL is held.
>>
>> [PATCH net-next] igmp: add __ip_mc_{join|leave}_group()
>>
>> There is a need to perform igmp join/leave operations while RTNL is
>> held. Make ip_mc_{join|leave}_group() wrappers around __ip_mc_{join|
>> leave}_group() to avoid the proliferation of work queues.
>
>
> Thanks. I will update my patch to use the new apis.
>
> Thanks.
>>
>>
>>
>>
>> ...
>>
>>
>

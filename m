From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 16:53:08 -0400
Message-ID: <CAHC9VhTm7Qc0FwEE35c5uyfWz-5DH1mKQtHGYrNVhPHm9ze34Q@mail.gmail.com>
References: <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
 <20161021193951.GS23701@madcap2.tricolour.ca> <CAHC9VhSm21f-HurdGi7+D0LmHNkkKRyAsT-OHJEyOZgoJVYUNg@mail.gmail.com>
 <20161021.163342.2187677530255875866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: rgb@redhat.com, xiyou.wangcong@gmail.com,
        Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
        e@eladraz.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:34987 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755258AbcJUUxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 16:53:10 -0400
Received: by mail-vk0-f68.google.com with SMTP id 130so5296947vkg.2
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 13:53:10 -0700 (PDT)
In-Reply-To: <20161021.163342.2187677530255875866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 4:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Paul Moore <paul@paul-moore.com>
> Date: Fri, 21 Oct 2016 16:15:00 -0400
>
>> However, that's not the case is it?  Unless I missed something, the
>> fix that Cong Wang is advocating (rework the audit multicast code), is
>> a change that I have said I'm not going to accept during the -rc
>> phase.  It has been a few days now and no alternate fix has been
>> proposed, I'll give it a few more hours ...
>
> It really is the right way to fix this though.
>
> Nothing should be emitting netlink messages, potentially en-masse
> to a multicast group or broadcast, in hardware interrupt context.
>
> I know it's been said that only systemd receives these things, so
> that point doesn't need to be remade again.

I think it is also worth noting that this code has been doing it this
way for some time now.  I say this not to advocate that it is correct,
only that there hasn't been a demonstrated problem until Cong Wang's
patch.

> We have many weeks until -final is released so I really don't
> understand the reluctance at a slightly more involved fix in -rc2.  In
> fact this is the most optimal time to try it this way, as we'll have
> the maximum amount of time for it to have exposure for testing before
> -final.

Well, I understand what you are trying to say, but the maximum amount
of time for exposure/testing would be to put it in -next.  The audit
netlink code needs a rework, but introducing such a change in the -rc
kernels is not something I'm going to do, especially when the change
which triggered the regression is an optimization that can be easily
reverted ... or fixed, but the only two options I've heard mentioned
are the audit multicast rework and the revert; if someone has a third
option I'm listening ...

-- 
paul moore
www.paul-moore.com

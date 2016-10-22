From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 20:53:42 -0700
Message-ID: <CAM_iQpVJd46SQuTE3Dm8nvCdv=rUQOsmxrMB3dSOCpwQV9eOZw@mail.gmail.com>
References: <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
 <20161021193951.GS23701@madcap2.tricolour.ca> <CAHC9VhSm21f-HurdGi7+D0LmHNkkKRyAsT-OHJEyOZgoJVYUNg@mail.gmail.com>
 <20161021.163342.2187677530255875866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul Moore <paul@paul-moore.com>,
        Richard Guy Briggs <rgb@redhat.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35266 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932826AbcJVDyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 23:54:04 -0400
Received: by mail-it0-f52.google.com with SMTP id 198so6385148itw.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 20:54:03 -0700 (PDT)
In-Reply-To: <20161021.163342.2187677530255875866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 1:33 PM, David Miller <davem@davemloft.net> wrote:
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

+1

>
> I know it's been said that only systemd receives these things, so
> that point doesn't need to be remade again.
>
> We have many weeks until -final is released so I really don't
> understand the reluctance at a slightly more involved fix in -rc2.  In
> fact this is the most optimal time to try it this way, as we'll have
> the maximum amount of time for it to have exposure for testing before
> -final.

Exactly, this is how release candidates work and this is why Linus usually
puts 6 or 7 rc's before a final release, so that we have 6/7 weeks to fix bugs
(and bugs of bug fixes of course) from the merge window.

It is very common we have hidden bugs before a merge window, since they
were just sitting in a subsystem maintainer's tree, more testers come in after
merge window, a bug like this one is clearly a cross-subsystem one, and
-rc2 a perfect time to fix it. This is how we work for years.

Audit subsystem is in a different world with the rest of us. Sigh.

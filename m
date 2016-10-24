From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] netns: revert "netns: avoid disabling irq for netns id"
Date: Mon, 24 Oct 2016 10:52:25 -0700
Message-ID: <CAM_iQpW+qoEKd5xtKx64ELanho+4Y_9SkZL5dQnBWmJ=T7VBiQ@mail.gmail.com>
References: <147710095406.17836.12069093425270216381.stgit@localhost>
 <CAM_iQpXd=8nHeCVKx4a5kBNf0mGb88i5eL=8+oaZcK-wKGVsXg@mail.gmail.com> <CAGH-Kgv6BXrTLPdsLfYnoU8nVeh7fTv89xPZixOS9qqPg8=PXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Stephen Smalley <sds@tycho.nsa.gov>
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36112 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752030AbcJXRwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 13:52:46 -0400
Received: by mail-oi0-f68.google.com with SMTP id e12so3187904oib.3
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 10:52:46 -0700 (PDT)
In-Reply-To: <CAGH-Kgv6BXrTLPdsLfYnoU8nVeh7fTv89xPZixOS9qqPg8=PXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 22, 2016 at 12:29 PM, Paul Moore <pmoore@redhat.com> wrote:
> On Fri, Oct 21, 2016 at 11:38 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Fri, Oct 21, 2016 at 6:49 PM, Paul Moore <pmoore@redhat.com> wrote:
>>> Eventually we should be able to reintroduce this code once we have
>>> rewritten the audit multicast code to queue messages much the same
>>> way we do for unicast messages.  A tracking issue for this can be
>>> found below:
>>
>> NAK.
>>
>> 1) This will be forgotten by Paul.
>
> The way things are going right now, this argument is going to devolve
> into a "yes he will"/"no I won't" so I'll just repeat that I've
> created a tracking issue for this so I won't forget (and included a
> link, repeated below, in the commit description) and I think I have a
> reasonable history of following through on things.
>
> * https://github.com/linux-audit/audit-kernel/issues/23

I never doubt you will remember to do the audit part, what you will
forget is the revert to your revert. We will see.

Also, you make git log history much uglier.

>
>> 2) There is already a fix which is considered as a rework by Paul.
>
> Already discussed this in the other thread, I'm not going to go into
> detail here, just a quick summary: the fix provided by Cong Wang
> doubles the message queue's memory consumption and changes some
> fundamentals in how multicast messages are handled.  The memory
> issues, while still an objectionable blocker, are easily resolved, but
> moving the netlink multicast send is something I want to make sure is
> tested/baked for a bit (it's 4.10 merge window material as far as I'm
> concerned).

Sounds like you don't have the capacity to get it reviewed and tested
within 5 weeks (assuming -rc7 will be the final RC), as a maintainer.


>
> At this point I think it is worth mentioning that we are in this
> position due to a lack of testing; if Cong Wang had tested his
> original patch with SELinux we might not be dealing with this
> regression now.  A more measured approach seems very reasonable.
>

My SELinux is silently disabled because CONFIG_DEFAULT_SECURITY_SELINUX=y
was missing in my kernel config. The change is a cross-subsystem one,
I definitely can't guarantee I can cover all subsystems. This is exactly
why we need -rc1...-rc7, the moment you close the door for -rc2,
the moment you lose the opportunity to get it tested more widely.
I am sure you will revert the revert of revert again for the next merge
window if you continue to work in this style.


>> 3) -rc2 is Paul's personal deadline, not ours.
>
> The current 4.9-rc kernels are broken and cause errors when SELinux is
> enabled, while I understand SELinux is not a priority (or a secondary,
> or tertiary, or N-ary concern) for many on the netdev list, it is
> still an important part of the kernel and this regression needs to be
> treated seriously and corrected soon.

You get it wrong, it is never because SELinux is not important, every
part of Linux kernel is important. You need to realize we as a whole
community don't work in this way, -rc2 is NOT late for a bug fix of any
part of Linux kernel. If you can't review and test a 30-line patch in 5 weeks,
it is very likely your problem.


>
> SELinux/audit has run into interaction issues with the network stack
> before, and we've worked together to sort things out; I'm hopeful
> cooler heads will prevail and we can do the same here.

I am trying my best to help (by providing 3 possible patches), you refused
them because of _your_ -rc2 deadline. Let people judge who is the one
doesn't work together.

I am tired of explaining why we have -rc7 to you.

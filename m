From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] netns: revert "netns: avoid disabling irq for netns id"
Date: Sat, 22 Oct 2016 15:29:49 -0400
Message-ID: <CAGH-Kgv6BXrTLPdsLfYnoU8nVeh7fTv89xPZixOS9qqPg8=PXQ@mail.gmail.com>
References: <147710095406.17836.12069093425270216381.stgit@localhost> <CAM_iQpXd=8nHeCVKx4a5kBNf0mGb88i5eL=8+oaZcK-wKGVsXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Stephen Smalley <sds@tycho.nsa.gov>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38300 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751241AbcJVT3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 15:29:51 -0400
Received: by mail-it0-f48.google.com with SMTP id 66so65908336itl.1
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 12:29:50 -0700 (PDT)
In-Reply-To: <CAM_iQpXd=8nHeCVKx4a5kBNf0mGb88i5eL=8+oaZcK-wKGVsXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 11:38 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Oct 21, 2016 at 6:49 PM, Paul Moore <pmoore@redhat.com> wrote:
>> Eventually we should be able to reintroduce this code once we have
>> rewritten the audit multicast code to queue messages much the same
>> way we do for unicast messages.  A tracking issue for this can be
>> found below:
>
> NAK.
>
> 1) This will be forgotten by Paul.

The way things are going right now, this argument is going to devolve
into a "yes he will"/"no I won't" so I'll just repeat that I've
created a tracking issue for this so I won't forget (and included a
link, repeated below, in the commit description) and I think I have a
reasonable history of following through on things.

* https://github.com/linux-audit/audit-kernel/issues/23

> 2) There is already a fix which is considered as a rework by Paul.

Already discussed this in the other thread, I'm not going to go into
detail here, just a quick summary: the fix provided by Cong Wang
doubles the message queue's memory consumption and changes some
fundamentals in how multicast messages are handled.  The memory
issues, while still an objectionable blocker, are easily resolved, but
moving the netlink multicast send is something I want to make sure is
tested/baked for a bit (it's 4.10 merge window material as far as I'm
concerned).

At this point I think it is worth mentioning that we are in this
position due to a lack of testing; if Cong Wang had tested his
original patch with SELinux we might not be dealing with this
regression now.  A more measured approach seems very reasonable.

> 3) -rc2 is Paul's personal deadline, not ours.

The current 4.9-rc kernels are broken and cause errors when SELinux is
enabled, while I understand SELinux is not a priority (or a secondary,
or tertiary, or N-ary concern) for many on the netdev list, it is
still an important part of the kernel and this regression needs to be
treated seriously and corrected soon.

SELinux/audit has run into interaction issues with the network stack
before, and we've worked together to sort things out; I'm hopeful
cooler heads will prevail and we can do the same here.

-- 
paul moore
security @ redhat

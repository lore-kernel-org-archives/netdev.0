From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Getting a handle on all these new NIC features
Date: Tue, 17 Jan 2017 16:01:49 -0800
Message-ID: <506ce907-64d3-a3b9-a24f-788a4132f2bc@gmail.com>
References: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35946 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdARABy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 19:01:54 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so65719333pfu.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 16:01:54 -0800 (PST)
In-Reply-To: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 02:05 PM, Tom Herbert wrote:
> I realize that backports of a driver is not a specific concern of the
> Linux kernel, but nevertheless this is a real problem and a fact of
> life for many users. Rebasing the full kernel is still a major effort
> and it seems the best we could ever do is one rebase per year. In the
> interim we need to occasionally backport drivers. Backporting drivers
> is difficult precisely because of new features or API changes to
> existing ones. These sort of changes tend to have a spiderweb of
> dependencies in other parts of the stack so that the number of patches
> we need to cherry-pick goes way beyond those that touch the driver we
> are interested in.

backports (formerly known as compat-wireless) dealt with that problem by
pulling in all dependencies from the networking stack (and beyond ),
this allowed people with a need to stay on a particular kernel version
to get the newest and latest networking bits and drivers with minor
disruption to other parts of the kernel. The project now seems to be
largely dead, but could be revived I presume:

https://backports.wiki.kernel.org/index.php/Main_Page

> 
> In short, I would like to ask if driver maintainers to start to
> modularize driver features. If something being added is obviously a
> narrow feature that only a subset of users will need can we allow
> config options to #ifdef those out somehow? 

Multiplying the number if #ifdef means that every config option is going
to be turned on by Linux distributions, and most likely just a subset
will be turned by specific kernel configurations (like yours), but all
in all, this multiplies the number of build combinations to a point
where this may not be manageable for an upstream driver and some
combinations won't be tested properly except by whoever diverges from
these. I understand the concern of modularizing and having clean
independent features/modules, I am unsure that more configuration
options is necessarily right approach.

Slightly tangential, once a series of patches lands in a given
maintainers' tree, it is very hard to match a given commit with its
original submission and say, locate the 11 other patches out of this 12
patch series adding feature XYZ of interest. David does a great job a
putting submissions in a branch, which helps a lot, but in general,
there is not enough information in git to associate a given patch with
its companion patches within a series, hence making backporting harder IMHO.
-- 
Florian

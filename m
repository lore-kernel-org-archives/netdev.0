From: Tom Herbert <tom@herbertland.com>
Subject: Getting a handle on all these new NIC features
Date: Tue, 17 Jan 2017 14:05:38 -0800
Message-ID: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36481 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750924AbdAQWGb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 17:06:31 -0500
Received: by mail-qt0-f182.google.com with SMTP id k15so183332651qtg.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 14:05:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was some discussion about the problems of dealing with the
explosion of NIC features in the mlx directory restructuring proposal,
but I think the is a deeper issue here that should be discussed.

It's hard not to notice that there has been quite a proliferation of
NIC features in several drivers. This trend had resulted in very
complex driver code that may or may not segment individual features.
One visible manifestation of this is number of ndo functions which is
somewhere around seventy-five now.

I suspect the vast majority of these advances NIC features (e.g.
bridging, UDP offloads, tc offload, etc.) are only relevant to some of
the people some of the time. The problem we have, in this case those
of us that are attempting to deploy and maintain NICs at scale, is
when we have to deal with the ramifications of these features being
intertwined with core driver functionality that is relevant to
everyone. This becomes very obvious when we need to backport drivers
from later versions of kernel.

I realize that backports of a driver is not a specific concern of the
Linux kernel, but nevertheless this is a real problem and a fact of
life for many users. Rebasing the full kernel is still a major effort
and it seems the best we could ever do is one rebase per year. In the
interim we need to occasionally backport drivers. Backporting drivers
is difficult precisely because of new features or API changes to
existing ones. These sort of changes tend to have a spiderweb of
dependencies in other parts of the stack so that the number of patches
we need to cherry-pick goes way beyond those that touch the driver we
are interested in.

Currently we (FB) need to backport two NIC drivers. I've already gave
details of backporting mlx5 on the thread to restructure the driver
directories. The other driver being backporting seems to suffer from
the same type of feature complexity.

In short, I would like to ask if driver maintainers to start to
modularize driver features. If something being added is obviously a
narrow feature that only a subset of users will need can we allow
config options to #ifdef those out somehow? Furthermore can the file
and directory structure of drivers reflect that; our lives would be
_so_ much simpler to maintain drivers in production if we have such
modularity and the ability to build drivers with the features of our
choosing.

Thanks,
Tom

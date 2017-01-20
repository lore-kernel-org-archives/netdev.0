From: Martin Habets <mhabets@solarflare.com>
Subject: Re: Getting a handle on all these new NIC features
Date: Fri, 20 Jan 2017 16:36:25 +0000
Message-ID: <9dcdea22-3692-1721-5951-f3a29d003e92@solarflare.com>
References: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:3993 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752780AbdATQnX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:43:23 -0500
In-Reply-To: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On 17/01/17 22:05, Tom Herbert wrote:
> There was some discussion about the problems of dealing with the
> explosion of NIC features in the mlx directory restructuring proposal,
> but I think the is a deeper issue here that should be discussed.
> 
> It's hard not to notice that there has been quite a proliferation of
> NIC features in several drivers. This trend had resulted in very
> complex driver code that may or may not segment individual features.
> One visible manifestation of this is number of ndo functions which is
> somewhere around seventy-five now.
> 
> I suspect the vast majority of these advances NIC features (e.g.
> bridging, UDP offloads, tc offload, etc.) are only relevant to some of
> the people some of the time. The problem we have, in this case those
> of us that are attempting to deploy and maintain NICs at scale, is
> when we have to deal with the ramifications of these features being
> intertwined with core driver functionality that is relevant to
> everyone. This becomes very obvious when we need to backport drivers
> from later versions of kernel.
> 
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

For the sfc driver (Solarflare Adapters) we currently do backports internally for:
 - RedHat Enterprise Linux		          5.10,  5.11
 - RedHat Enterprise Linux		          6.5, 6.6, 6.7, 6.8
   - Redhat Messaging Realtime and Grid           2.5
 - RedHat Enterprise Linux 		          7.0, 7.1, 7.2
   - RedHat Enterprise Linux for Realtime	  7.1, 7.2
 - SuSE Linux Enterprise Server 11                sp3, sp4
   - SuSE Linux Enterprise RealTime Extension 11  
 - SuSE Linux Enterprise Server 12                base release, sp1
 - Canonical Ubuntu Server LTS                    14.04, 16.04
 - Canonical Ubuntu Server                        -
 - Debian 7 "Wheezy"                              7.X
 - Debian 8 "Jessie"                              8.X
 - Linux                                          2.6.18 to 4.9-rc1

We update this list as needed, and always try to support the latest kernel.
I do not know if that would cover the kernel version you are using.

Best regards,
Martin

> Currently we (FB) need to backport two NIC drivers. I've already gave
> details of backporting mlx5 on the thread to restructure the driver
> directories. The other driver being backporting seems to suffer from
> the same type of feature complexity.
> 
> In short, I would like to ask if driver maintainers to start to
> modularize driver features. If something being added is obviously a
> narrow feature that only a subset of users will need can we allow
> config options to #ifdef those out somehow? Furthermore can the file
> and directory structure of drivers reflect that; our lives would be
> _so_ much simpler to maintain drivers in production if we have such
> modularity and the ability to build drivers with the features of our
> choosing.
> 
> Thanks,
> Tom

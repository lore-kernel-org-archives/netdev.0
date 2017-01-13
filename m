From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Sat, 14 Jan 2017 00:45:52 +0200
Message-ID: <CALzJLG_RsvgszVxGZ7+VgYjET9w=XTjq36Z72diOQFNJWz9tQw@mail.gmail.com>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net> <20170113202932.GS20392@mtr-leonro.local>
 <CALx6S37hb78RJ8tCtsCsX2fg6e-D+naNpSQo6T2AyWMd0U74sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leon@kernel.org>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36808 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdAMWqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:46:14 -0500
Received: by mail-qk0-f193.google.com with SMTP id a20so9094903qkc.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 14:46:14 -0800 (PST)
In-Reply-To: <CALx6S37hb78RJ8tCtsCsX2fg6e-D+naNpSQo6T2AyWMd0U74sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2017 at 12:06 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Jan 13, 2017 at 12:29 PM, Leon Romanovsky <leon@kernel.org> wrote:
>> On Fri, Jan 13, 2017 at 12:14:07PM -0500, David Miller wrote:
>>> From: Saeed Mahameed <saeedm@mellanox.com>
>>> Date: Thu, 12 Jan 2017 19:22:34 +0200
>>>
>>> > This pull request includes one patch from Leon, this patch as described
>>> > below will change the driver directory structure and layout for better,
>>> > logical and modular driver files separation.
>>> >
>>> > This change is important to both rdma and net maintainers in order to
>>> > have smoother management of driver patches for different mlx5 sub modules
>>> > and smoother rdma-next vs. net-next features submissions.
>>> >
>>> > Please find more info below -in the tag commit message-,
>>> > review and let us know if there's any problem.
>>> >
>>> > This change doesn't introduce any conflicts with the current mlx5
>>> > fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
>>> > worked flawlessly with no issues.
>>> >
>>> > This is the last pull request meant for both rdma-next and net-next.
>>> > Once pulled, this will be the base shared code for both trees.
>>>
>>> This is pretty crazy, it will make all bug fix backporting to -stable
>>> a complete nightmare for myself, Doug, various distribution maintainers
>>> and many other people who quietly have to maintain their own trees and
>>> do backporting.
>>
>> Hi Dave,
>>
>> I understand your worries, but our case is similar to various other
>> drivers, for example hfi1 which was in staging for years while
>> supported in RedHat and moved from there to IB. The Chelsio drivers did
>> similar reorg in 2016 (drivers/net/ethernet/chelsio/libcxgb) while their
>> drivers were in the tree for long time before.
>>
>> Additionally, Doug doesn't need to maintain -stable queue and it is done
>> by relevant submaintainers who are adding stable tags by themselves. In
>> the IB case, the burden will continue to be on me and not on Doug.
>>
> Recently I had to backport the mlx5 driver from 4.9 to 4.6 in order to
> get support for XDP. The biggest issue I faced was the lack of
> modularity in the many driver features that are now supported. The
> problem with backporting these new features is the spider web of
> dependencies that they bring in from the rest of the kernel. I ended
> up taking out en_rep, vxlan, en_tc, eswitch, and dcbnl. The result was
> ~340 patches which is still a lot but at least this was constrained to
> patches in the mlx5 directories and are relevant to what we want to
> do.
>
> In lieu of restructuring the directories, I would much rather see more
> config options so that we can build drivers that don't unnecessarily
> complicate our lives with features we don't use. This is not just true
> for Mellanox, but I would say it would be true of any driver that
> someone is trying to deploy and maintain at large scale.
>

I think we should have both, if the restructuring made right,
new whole features (e.g eswitch and eswitch offlaods or any independent module),
can sit in their own directory and keep their own logic concentrated
in one place, and only touch the
main driver code with simple entry points in the main flow,  this way
you can simply compile their whole directories
out with a config flag directly from the Makefile.

> Btw, we did hit one issue in the backport. We started to get rx csum
> faults (checksum complete value indicates TCP checksum is bad, but
> host computation says checksum is good). I ran against 4.9 upstream
> kernel and do see these, however don't see them in 4.10. I haven't
> bisected yet. Is this a known issue?
>

Not to me, I don't recall any csum related fixes or feature submitted
lately to mlx5,
Maybe something changed in the stack ?

what configuration are you running ? what traffic ?

> Thanks,
> Tom
>
>>>
>>> I really don't think you can justify this rearrangement based upon the
>>> consequences and how much activity happens in this driver.
>>>
>>> You should have thought long and hard about the layout a long time ago
>>> rather than after the driver has been in the tree for many years.
>>>
>>> Sorry.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

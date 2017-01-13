From: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Fri, 13 Jan 2017 14:56:32 -0800
Message-ID: <CALx6S35cSnMoBtxi+Eb_mH=LCLy9yY6U5sxofndce9r0eCs8+w@mail.gmail.com>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net> <20170113202932.GS20392@mtr-leonro.local>
 <CALx6S37hb78RJ8tCtsCsX2fg6e-D+naNpSQo6T2AyWMd0U74sQ@mail.gmail.com> <CALzJLG_RsvgszVxGZ7+VgYjET9w=XTjq36Z72diOQFNJWz9tQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG_RsvgszVxGZ7+VgYjET9w=XTjq36Z72diOQFNJWz9tQw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2017 at 2:45 PM, Saeed Mahameed
<saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> On Sat, Jan 14, 2017 at 12:06 AM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
>> On Fri, Jan 13, 2017 at 12:29 PM, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>> On Fri, Jan 13, 2017 at 12:14:07PM -0500, David Miller wrote:
>>>> From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>>> Date: Thu, 12 Jan 2017 19:22:34 +0200
>>>>
>>>> > This pull request includes one patch from Leon, this patch as described
>>>> > below will change the driver directory structure and layout for better,
>>>> > logical and modular driver files separation.
>>>> >
>>>> > This change is important to both rdma and net maintainers in order to
>>>> > have smoother management of driver patches for different mlx5 sub modules
>>>> > and smoother rdma-next vs. net-next features submissions.
>>>> >
>>>> > Please find more info below -in the tag commit message-,
>>>> > review and let us know if there's any problem.
>>>> >
>>>> > This change doesn't introduce any conflicts with the current mlx5
>>>> > fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
>>>> > worked flawlessly with no issues.
>>>> >
>>>> > This is the last pull request meant for both rdma-next and net-next.
>>>> > Once pulled, this will be the base shared code for both trees.
>>>>
>>>> This is pretty crazy, it will make all bug fix backporting to -stable
>>>> a complete nightmare for myself, Doug, various distribution maintainers
>>>> and many other people who quietly have to maintain their own trees and
>>>> do backporting.
>>>
>>> Hi Dave,
>>>
>>> I understand your worries, but our case is similar to various other
>>> drivers, for example hfi1 which was in staging for years while
>>> supported in RedHat and moved from there to IB. The Chelsio drivers did
>>> similar reorg in 2016 (drivers/net/ethernet/chelsio/libcxgb) while their
>>> drivers were in the tree for long time before.
>>>
>>> Additionally, Doug doesn't need to maintain -stable queue and it is done
>>> by relevant submaintainers who are adding stable tags by themselves. In
>>> the IB case, the burden will continue to be on me and not on Doug.
>>>
>> Recently I had to backport the mlx5 driver from 4.9 to 4.6 in order to
>> get support for XDP. The biggest issue I faced was the lack of
>> modularity in the many driver features that are now supported. The
>> problem with backporting these new features is the spider web of
>> dependencies that they bring in from the rest of the kernel. I ended
>> up taking out en_rep, vxlan, en_tc, eswitch, and dcbnl. The result was
>> ~340 patches which is still a lot but at least this was constrained to
>> patches in the mlx5 directories and are relevant to what we want to
>> do.
>>
>> In lieu of restructuring the directories, I would much rather see more
>> config options so that we can build drivers that don't unnecessarily
>> complicate our lives with features we don't use. This is not just true
>> for Mellanox, but I would say it would be true of any driver that
>> someone is trying to deploy and maintain at large scale.
>>
>
> I think we should have both, if the restructuring made right,
> new whole features (e.g eswitch and eswitch offlaods or any independent module),
> can sit in their own directory and keep their own logic concentrated
> in one place, and only touch the
> main driver code with simple entry points in the main flow,  this way
> you can simply compile their whole directories
> out with a config flag directly from the Makefile.
>
>> Btw, we did hit one issue in the backport. We started to get rx csum
>> faults (checksum complete value indicates TCP checksum is bad, but
>> host computation says checksum is good). I ran against 4.9 upstream
>> kernel and do see these, however don't see them in 4.10. I haven't
>> bisected yet. Is this a known issue?
>>
>
> Not to me, I don't recall any csum related fixes or feature submitted
> lately to mlx5,
> Maybe something changed in the stack ?
>
> what configuration are you running ? what traffic ?
>
Nothing fancy. 8 queues and 20 concurrent netperf TCP_STREAMs trips
it. Not a lot of them, but I don't think we really should ever see
these errors.

Tom

>> Thanks,
>> Tom
>>
>>>>
>>>> I really don't think you can justify this rearrangement based upon the
>>>> consequences and how much activity happens in this driver.
>>>>
>>>> You should have thought long and hard about the layout a long time ago
>>>> rather than after the driver has been in the tree for many years.
>>>>
>>>> Sorry.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

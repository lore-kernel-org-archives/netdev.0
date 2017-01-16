From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Tue, 17 Jan 2017 01:36:44 +0200
Message-ID: <CALzJLG8a3nrs=6dUSP56WuMrHmGaJLx19X=HWwYWyM0vQeTk=Q@mail.gmail.com>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net> <CALzJLG_fjiGyuB_buZqOSMU7SaCnuqFiZ0UyW+hPDq+3yx7TWg@mail.gmail.com>
 <CALzJLG--ZRVk0Zy+6UaGCWbOhki+PZnkmrh9rjojU1ZDm_5Y6w@mail.gmail.com> <CALx6S377hzH8_DbUSKafkbCzMEunr0H7vrfcb2WfEWFHFnfUpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALx6S377hzH8_DbUSKafkbCzMEunr0H7vrfcb2WfEWFHFnfUpw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2017 at 11:06 PM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
> On Mon, Jan 16, 2017 at 12:30 PM, Saeed Mahameed
> <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>> On Sat, Jan 14, 2017 at 12:07 AM, Saeed Mahameed
>> <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>>> On Fri, Jan 13, 2017 at 7:14 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>>>> From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>>>> Date: Thu, 12 Jan 2017 19:22:34 +0200
>>>>
>>>>> This pull request includes one patch from Leon, this patch as described
>>>>> below will change the driver directory structure and layout for better,
>>>>> logical and modular driver files separation.
>>>>>
>>>>> This change is important to both rdma and net maintainers in order to
>>>>> have smoother management of driver patches for different mlx5 sub modules
>>>>> and smoother rdma-next vs. net-next features submissions.
>>>>>
>>>>> Please find more info below -in the tag commit message-,
>>>>> review and let us know if there's any problem.
>>>>>
>>>>> This change doesn't introduce any conflicts with the current mlx5
>>>>> fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
>>>>> worked flawlessly with no issues.
>>>>>
>>>>> This is the last pull request meant for both rdma-next and net-next.
>>>>> Once pulled, this will be the base shared code for both trees.
>>>>
>>>> This is pretty crazy, it will make all bug fix backporting to -stable
>>>> a complete nightmare for myself, Doug, various distribution maintainers
>>>> and many other people who quietly have to maintain their own trees and
>>>> do backporting.
>>>>
>>>
>>> I hear you,
>>> But please bear with me here, what if we queue this patch up to -stable ? and we
>>> (Mellanox) and specifically our dedicated inbox team, will make sure
>>> that this patch
>>> will land on the various distributions and for those maintaining their
>>> own trees.
>>> This patch is really straight forward (rename files) and I already
>>> tried to cherry-pick it
>>> on older kernels, I only got a couple of conflicts on some of the
>>> "#inlcude" lines we've
>>> changed, and they are pretty straightforward to fix, we can even avoid
>>> this if we decide to
>>> not move mlx5 header files in this phase.
>>>
>>> If this is possible then all trees will be aligned and it will be a
>>> win win situation.
>>>
>>
>> Hi Dave,
>>
>> Any chance you saw my -stable suggestion above ?
>> I think it would really close the backporting gap.
>>
>> Sorry i am bothering you with this topic, but we really desire the new
>> structure and
>> I never got your feedback on this suggestion, so i would like to hear
>> your thoughts.
>>
> Saeed,
>
> I've already you specific suggestions on your new structure, please
> consider your reviewers feedback more carefully. Again, the starting

I know, sorry i didn't respond on time, I though Leno's response was sufficient.

> point for your restructuring should be to separate out the minimum set
> of files required to build reasonable driver and then cleanly
> compartmentalize the rest of the features to make it easy for your
> users to include or not include those in their build. Unless you've

I see your point and i am 100% with you on this, we are all on the
same page here,
we all want to achieve the same goal -modular break down and features
logic separation-.

And in order to achieve this we need to do some big steps.
some of them will have real benefits and others are just moving code around.

One thing I need to point out (that Leon already mentioned) that the
current driver files sitting flat
in mlx5/core directory can be categorized to 4 categories
1. core related & init flows
2. common (infinband/ethernet resource management API)
3. infiniband related logic and FW commands
4. ethernet related logic and FW commands

so we figured that first we should split the bigger chunks (ethernet
vs. inifniband) into their own directories.
then i can follow up with ethernet features break down and kconfig separation.

> done this I'm not seeing much benefit for this restructuring. Also, I
> would rather see this done in one shot then expecting some sort of
> evolution over time to the right solution-- as Dave said the
> complexity of this driver is to far down the road to do that.
>

Well, I also prefer to do this in one shot, but I don't want to start
wasting time doing such a huge change
then get a NACK on submission.

Let's assume we did this in one shot i.e:
1. restructure  files and directories
2. re-arrange code (separate logic)
3. Kconfig features control - to show the immediate benefit of this change

If this is acceptable by you and we get Dave's blessing on this then i
would be happy to provide (as this is our
long term plan), but if Dave doesn't approve, then ... I don't really know.

Also for 1. backporting is really easy since such patch can be applied
easily to any kernel release back to 4.4.
but 2. and 3. are really tricky ones.

> Tom
>
>> Thanks,
>> Saeed.
>>
>>>> I really don't think you can justify this rearrangement based upon the
>>>> consequences and how much activity happens in this driver.
>>>>
>>>
>>> Right, but this is not the only justification, I can sum it up to that
>>> we would like
>>> to lay out the foundation for many years to come for a well designed
>>> driver with a modular
>>> sub modules break down and scalable infrastructure. We already plan to
>>> submit more mlx5
>>> independent  sub modules - just like mlx5e (en_*) files and mlx5_ib
>>> driver- so this was also
>>> a reason for us to consider this re-engagement at this stage.
>>>
>>>> You should have thought long and hard about the layout a long time ago
>>>> rather than after the driver has been in the tree for many years.
>>>>
>>>
>>> I had this Idea for the separation before the mlx5 Ethernet
>>> submission, but I wasn't the maintainer
>>> back then, and i have been itching to submit such patch for long as
>>> well, still i don't think
>>> it is too late, We (Me and Leon) will keep maintaining this driver for
>>> only god knows how many years to come,
>>> and the mlx5 drivers are meant to serve at least 3-4 more future HW generations.
>>>
>>> Long story short, We would like to re-arrange the driver in a way that
>>> would serve us (the maintainers) and serve those
>>> who are going do develop the future Stack features and the future HW
>>> generations over the well designed (Hopefully)
>>> mlx5 infrastructure.
>>> Keeping it as it is today, will only make the situation worst in the
>>> future and it will be really hard to avoid having a spaghetti code
>>> in the mlx5 driver. All i want to point out here is that maintaining
>>> such a flat subtree is also nightmare.
>>>
>>> So i am only asking you to reconsider this change and give my -stable
>>> suggestion a thought.
>>>
>>> Thank you.
>>> Saeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

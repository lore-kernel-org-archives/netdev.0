From: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Sun, 2 Aug 2015 10:56:38 +0300
Message-ID: <55BDCD36.6000301@mellanox.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
 <55BB6F10.5030408@redhat.com> <20150731163201.GA6027@obsidianresearch.com>
 <55BBB353.7020806@redhat.com>
 <CAJ3xEMiP57qf58B=VHRazs50RC5r-7OsUPb=GV1kBQ6vu6Tqjw@mail.gmail.com>
 <20150731220102.GA31209@obsidianresearch.com>
 <CAJ3xEMjgvgvc8WyUhHagiH4gNs6KK7pL_TmhXCywNiWEy4p70w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Somnath Kotur" <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMjgvgvc8WyUhHagiH4gNs6KK7pL_TmhXCywNiWEy4p70w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 8/2/2015 12:48 AM, Or Gerlitz wrote:
> On Sat, Aug 1, 2015 at 1:01 AM, Jason Gunthorpe
> <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
>> On Sat, Aug 01, 2015 at 12:24:23AM +0300, Or Gerlitz wrote:
>>
>>> addressed in incremental patch, as Doug suggested. Jason, it's wrong
>>> to send developers again and again to fix things which were
>>> perfect in Vn-1 but also not being covered by reviewers on Vn-1, at
>>> some point the reviewer can't load new comments which gate the
>>
>> I don't even know what you are talking about Or.
>>
>> v6 had some small problems in the logic and v7 introduces a fairly
>> serious flaw while trying to fix them. IMHO, you are better to merge
>> v6 than v7, at least v6's problems are less likely to be serious.
>
> Jason, can you be more specific? I don't see any comments from you
> expect for the cover-letter, so if something broke out, sure, a fix is
> needed, but what is that?
>
>> That is the same argument you used for the timestamp _ex UAPI mess,
>> last cycle, where are the incremental fixes for that?
>
> I remember you have provided review comment which pointed that the
> time-stamping series stepped on something which was there before needs
> some cleanup, not a real mess to my taste. Matan, do have the plan to
> do that work?

Indeed this design flaw was introduced when the first legacy verb was
extended. I think that falling back from extended code to legacy code
should be in the uverbs code. ib_uverbs_write will return -ENOSYS only
if both extended and non-extended don't exist. The uverbs command itself 
will call the non-extended form if the comp_mask is zero and all
data between legacy size and the given size are zero as well.
What do you think?

>
> Or.
>

Matan
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

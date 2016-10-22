From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 20:26:51 -0700
Message-ID: <CAM_iQpWfVWmG3egCXwbHSPEibtnh6G62xcFC9XXBNdojBqYCOg@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
 <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
 <CAHC9VhQWWDHnQGv+feXZ_CDrkftuRkKLtKvXkpN0pqh6e6hMPQ@mail.gmail.com>
 <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com> <CAHC9VhRQ9YAr9eHYg2HWusuCZd714tK6SSr3Et8beb77w37TUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36170 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755988AbcJVD1M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 23:27:12 -0400
Received: by mail-it0-f67.google.com with SMTP id 66so1663513itl.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 20:27:12 -0700 (PDT)
In-Reply-To: <CAHC9VhRQ9YAr9eHYg2HWusuCZd714tK6SSr3Et8beb77w37TUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 1:03 PM, Paul Moore <paul@paul-moore.com> wrote:
> On Fri, Oct 21, 2016 at 2:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Fri, Oct 21, 2016 at 9:19 AM, Paul Moore <paul@paul-moore.com> wrote:
>>> On Thu, Oct 20, 2016 at 7:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>> This is what I did in the follow up patch. I attach the updated version
>>>> in this email for you to review ...
>>>
>>> I think there is still some confusion.  The second patch you posted
>>> still has two queues with potentially duplicated (minus the length
>>> tweaks) skbs.
>>
>> The current code without my patch is already this, the only difference
>> is there is no queue for multicast case, duplication is already there.
>
> The difference is the period of time where the skbs are duplicated.
> You patch duplicates the skb and then queues them, I'm suggesting
> putting a single skb in the queue and then only duplicating it once it
> has been pulled off the queue.

I never disagree, the only thing you never explain is why we must do
it in this patch rather than a patch later?


>
>> So, why do you expect me to fix two problems in one patch? This
>> is totally unfair, it is probably based on your eager to revert...
>
> All I've been asking for this week is a fix before -rc2 is released; I


Why -rc2? Not -rc3 ... -rc7? Why should we, as a community, care
about a release candidate and specifically -rc2? If that is your own
schedule, why not cooperating with Linus' schedule to make other
people like me easy?


> think I've been pretty clear and consistent about that.  At the start
> of the week I didn't care if it was a revert or some other fix, so
> long as the fix was relatively small and easily verified/tested.  I
> did say that if we got to the end of the week and we didn't have a
> solution in place I would advocate for a revert.  It's Friday
> afternoon as I type this.

Blame the one who makes things unnecessarily complicated, please.
I am all for it.

>
> I've also been pretty clear from the very beginning that I don't
> consider a rework of the audit multicast code to be a candidate for
> 4.9-rcX, that is -next material as far as I'm concerned.  I'll readily

Calling a change of 30 lines a rework?? OMG... We definitely have
different definitions for rework. Many stable backports are more than
this size... (I know the number of lines can't tell everything, but it tells
something.)


> admit that perhaps I'm more conservative than most maintainers, but I
> take that approach to try to keep from breaking other subsystems (and
> avoid situations like these, because this thread is so much fun after
> all).


I totally understand your conservative, but in the meantime, please be
rational. If -rc7 is the final RC, then we have 5 weeks away.


>>> What I am talking about is queuing the skb in audit_log_end(), without
>>> any modification, waking up the kauditd_thread, and then letting the
>>> kauditd_thread() function do both the netlink multicast and unicast
>>> sends, complete with the skb_copy() and length tweaks.  This way we
>>> only queue one copy of the skb.  To help make this more clear, I'll
>>> work up a patch and CC you.
>>
>> Sure, I hate the skb_copy() too since it could be in a IRQ handler,
>> I didn't remove it because that would make the patch more complicated
>> than the current one. We can always improve this later for the next merge
>> window, can't we? Why are you pushing something irrelevant to my
>> patch to make it unnecessarily complicated?
>
> I don't even know where to begin ... please just re-read what I've
> said above as well as previously this week.  I just want a simple fix
> for 4.9-rc.  I'm not going to sign-off/ack a rework of the audit
> multicast code for 4.9-rc.


Calling a 30-line patch a rework is just unfair.


>
>>> However, let me say this one more time: this is *NOT* a change I want
>>> to make during the -rcX cycle, this is a change that we should do for
>>> -next and submit during the next merge window after is has been tested
>>> and soaked in linux-next.  Given where we are at right now - it's
>>> Friday and I expect -rc2 on Sunday - I think the best course of action
>>> is to revert the original patch and move on.  I'm going to do that now
>>> and I'll submit it to netdev as soon as I've done some basic sanity
>>> checks.
>>
>> The problem with this is: I would have to revert this revert for the next
>> merge window, in the end you would have the following in git log:
>>
>> 1) original one
>> 2) revert
>> 3) audit fix
>> 4) revert the above revert
>>
>> comparing with:
>>
>> 1) original one
>> 2) audit fix
>>
>> You just want to make things unnecessarily complicated.
>
> No.  What I want, (one more time) is a fix in -rc2.

You have a fix, you refuse, you consider it as a rework. It's your problem.

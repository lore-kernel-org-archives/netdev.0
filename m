From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Fri, 21 Oct 2016 16:15:00 -0400
Message-ID: <CAHC9VhSm21f-HurdGi7+D0LmHNkkKRyAsT-OHJEyOZgoJVYUNg@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
 <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
 <CAHC9VhQWWDHnQGv+feXZ_CDrkftuRkKLtKvXkpN0pqh6e6hMPQ@mail.gmail.com>
 <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com> <20161021193951.GS23701@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:36853 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753745AbcJUUPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 16:15:03 -0400
Received: by mail-ua0-f196.google.com with SMTP id 38so279296uaj.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 13:15:02 -0700 (PDT)
In-Reply-To: <20161021193951.GS23701@madcap2.tricolour.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 3:39 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-10-21 11:02, Cong Wang wrote:
>> On Fri, Oct 21, 2016 at 9:19 AM, Paul Moore <paul@paul-moore.com> wrote:
>> > On Thu, Oct 20, 2016 at 7:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> >> This is what I did in the follow up patch. I attach the updated version
>> >> in this email for you to review ...
>> >
>> > I think there is still some confusion.  The second patch you posted
>> > still has two queues with potentially duplicated (minus the length
>> > tweaks) skbs.
>>
>> The current code without my patch is already this, the only difference
>> is there is no queue for multicast case, duplication is already there.
>> So, why do you expect me to fix two problems in one patch? This
>> is totally unfair, it is probably based on your eager to revert...
>>
>> >
>> > What I am talking about is queuing the skb in audit_log_end(), without
>> > any modification, waking up the kauditd_thread, and then letting the
>> > kauditd_thread() function do both the netlink multicast and unicast
>> > sends, complete with the skb_copy() and length tweaks.  This way we
>> > only queue one copy of the skb.  To help make this more clear, I'll
>> > work up a patch and CC you.
>>
>> Sure, I hate the skb_copy() too since it could be in a IRQ handler,
>> I didn't remove it because that would make the patch more complicated
>> than the current one. We can always improve this later for the next merge
>> window, can't we? Why are you pushing something irrelevant to my
>> patch to make it unnecessarily complicated?
>>
>>
>> > However, let me say this one more time: this is *NOT* a change I want
>> > to make during the -rcX cycle, this is a change that we should do for
>> > -next and submit during the next merge window after is has been tested
>> > and soaked in linux-next.  Given where we are at right now - it's
>> > Friday and I expect -rc2 on Sunday - I think the best course of action
>> > is to revert the original patch and move on.  I'm going to do that now
>> > and I'll submit it to netdev as soon as I've done some basic sanity
>> > checks.
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
> I agree here.  I've been following this, thinking about it, but don't
> yet have a solid recommendation about the way to proceed yet, but
> reverting it does not seem like the right solution.
>
>> You need to really CALM DOWN, -rc2 is NOT late, assuming -rc7 is the final
>> release candidate, we still have 5 weeks to fix it, why are you so scared?
>
> A revert seems pretty impulsive to me now.

I agree that if this issue had been identified today, it would be
impulsive to do a revert for -rc2; Stephen reported this problem
Wednesday morning.  I would also be okay waiting on a fix past -rc2 if
the solution was still under development and we all agreed on the
solution.

However, that's not the case is it?  Unless I missed something, the
fix that Cong Wang is advocating (rework the audit multicast code), is
a change that I have said I'm not going to accept during the -rc
phase.  It has been a few days now and no alternate fix has been
proposed, I'll give it a few more hours ...

-- 
paul moore
www.paul-moore.com

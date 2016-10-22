From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Sat, 22 Oct 2016 15:02:56 -0400
Message-ID: <CAHC9VhSNjx65rDKHLGy3ziZeoDzzBNUzXzWDOczDn=1Uh92+wQ@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
 <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
 <CAHC9VhQWWDHnQGv+feXZ_CDrkftuRkKLtKvXkpN0pqh6e6hMPQ@mail.gmail.com>
 <CAM_iQpV0vfwsToR=maxhGM+fvQLX9zqcpp14A-C9JNzLfKJy9g@mail.gmail.com>
 <CAHC9VhRQ9YAr9eHYg2HWusuCZd714tK6SSr3Et8beb77w37TUA@mail.gmail.com> <CAM_iQpWfVWmG3egCXwbHSPEibtnh6G62xcFC9XXBNdojBqYCOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:34447 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752726AbcJVTC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 15:02:58 -0400
Received: by mail-ua0-f173.google.com with SMTP id m26so17581257uaa.1
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 12:02:57 -0700 (PDT)
In-Reply-To: <CAM_iQpWfVWmG3egCXwbHSPEibtnh6G62xcFC9XXBNdojBqYCOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 11:26 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Oct 21, 2016 at 1:03 PM, Paul Moore <paul@paul-moore.com> wrote:
>> On Fri, Oct 21, 2016 at 2:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Fri, Oct 21, 2016 at 9:19 AM, Paul Moore <paul@paul-moore.com> wrote:
>>>> On Thu, Oct 20, 2016 at 7:35 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>> This is what I did in the follow up patch. I attach the updated version
>>>>> in this email for you to review ...
>>>>
>>>> I think there is still some confusion.  The second patch you posted
>>>> still has two queues with potentially duplicated (minus the length
>>>> tweaks) skbs.
>>>
>>> The current code without my patch is already this, the only difference
>>> is there is no queue for multicast case, duplication is already there.
>>
>> The difference is the period of time where the skbs are duplicated.
>> You patch duplicates the skb and then queues them, I'm suggesting
>> putting a single skb in the queue and then only duplicating it once it
>> has been pulled off the queue.
>
> I never disagree, the only thing you never explain is why we must do
> it in this patch rather than a patch later?

It seems obvious: if you do the skb_copy() before you queue the skbs
you are doubling the amount of memory used which is undesirable.

-- 
paul moore
www.paul-moore.com

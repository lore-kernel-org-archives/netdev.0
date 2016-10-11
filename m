From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Tue, 11 Oct 2016 10:36:21 -0700
Message-ID: <CAM_iQpV9+vzs4DWFcH2eMg+5pKb-UMEdhZ-UrJq73ubcMYiU=A@mail.gmail.com>
References: <20161002031349.GB2635@templeofstupid.com> <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com> <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
 <20161006061150.GA2525@templeofstupid.com> <CAM_iQpX7fC0HWz2X2R7uZNeiD_rEAe4QcSQiK+YZEHF8jkGBBA@mail.gmail.com>
 <20161009061331.GB2677@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32942 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754513AbcJKRhM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 13:37:12 -0400
Received: by mail-io0-f193.google.com with SMTP id q192so2036359iod.0
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 10:36:42 -0700 (PDT)
In-Reply-To: <20161009061331.GB2677@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 8, 2016 at 11:13 PM, Krister Johansen
<kjlx@templeofstupid.com> wrote:
> Hi Cong,
> Thanks for the follow-up.
>
> On Thu, Oct 06, 2016 at 12:01:15PM -0700, Cong Wang wrote:
>> On Wed, Oct 5, 2016 at 11:11 PM, Krister Johansen
>> > pernet_operations pointer.  The code in register_pernet_subsys() makes
>> > no attempt to check for duplicates.  If we add a pointer that's already
>> > in the list, and subsequently call unregister, the results seem
>> > undefined.  It looks like we'll remove the pernet_operations for the
>> > existing action, assuming we don't corrupt the list in the process.
>> >
>> > Is this actually safe?  If so, what corner case is the act->type /
>> > act->kind protecting us from?
>>
>> ops->type and ops->kind should be unique too, user-space already
>> relies on this (tc action ls action xxx). The code exists probably just
>> for sanity check.
>
> With that in mind, would it make sense to change the check to a WARN/BUG
> or some kind of assertion?  I mistakenly inferred that it was possible to
> legtimately end up in this scenario.


Yes, it makes sense to me.


>> > Part of the desire to inhibit extra modprobe calls is that if hundreds
>> > of these all start at once on boot, it's really unnecessary to have all
>> > of the rest of them wait while lots of extra modprobe calls are forked
>> > by the kernel.
>>
>> You can tell systemd to load these modules before starting these
>> containers to avoid blocking, no?
>
> That was exactly what I did to work around the panic until I was able to
> get a patch together.  The preload of the modules is still occurring,
> but I was hoping to excise that workaround entirely.

Or you can compile these modules into kernel, but I am not sure about
the dependencies. :-D

Thanks.

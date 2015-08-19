From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 7/9] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 19 Aug 2015 13:14:34 -0700
Message-ID: <CALnjE+qQiYozh6epodtHs1pk=1gq=68wdm71Jzv7pWqTDV9bow@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-8-git-send-email-pshelar@nicira.com>
	<CAEP_g=_4FHejf_qfXbXzO3kyx1WJ2ssOY9OMF=vySFNu-CPOqA@mail.gmail.com>
	<CALnjE+ojRD_QKY3A9EomCg6yZ2BR+jiSFjndzN+U+8aBP2b7GQ@mail.gmail.com>
	<CAEP_g=8Wq1jmrWT6a9K55JJsMNxw+Rw0h2zDby_HR6b12LJ5+w@mail.gmail.com>
	<CALnjE+rmdPOAFo876pZr-vtr=YmGZopSNPC02Qb3J0Wx3GBz1w@mail.gmail.com>
	<CAEP_g=9U_DtUrHpbASu+RJ5kZQmjXsysBX5DQWVMrj69KcnHYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:32973 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbbHSUOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:14:35 -0400
Received: by iods203 with SMTP id s203so22670741iod.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:14:34 -0700 (PDT)
In-Reply-To: <CAEP_g=9U_DtUrHpbASu+RJ5kZQmjXsysBX5DQWVMrj69KcnHYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 12:50 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Wed, Aug 19, 2015 at 11:49 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Wed, Aug 19, 2015 at 11:37 AM, Jesse Gross <jesse@nicira.com> wrote:
>>> On Wed, Aug 19, 2015 at 11:29 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>>> On Wed, Aug 19, 2015 at 11:18 AM, Jesse Gross <jesse@nicira.com> wrote:
>>>>> My guess is that if the issue from the earlier patch about overlapping
>>>>> collect_md tunnels is fixed then that might allow us to simplify
>>>>> things a little further, since for those tunnels we can assume there
>>>>> is a 1:1 mapping between collect_md tunnels and sockets.
>>>>
>>>> I dont see how it would be different. Can you elaborate on this ?
>>>
>>> Mostly just conceptually simpler. Right now it looks like we are doing
>>> some kind of refcounting between devices and tunnels in
>>> geneve_open/stop (I know it's not really but it appears like that in
>>> some ways.) We could just directly assign collect_md in geneve_open()
>>> and do nothing at all in geneve_stop().
>>
>> If you look at next patch, I have changed geneve_open and stop
>> further. The change is geneve_open adds tunnel to hash table so that
>> only device which are open are in hash table. Since geneve_open and
>> stop is common for both type of tunnel I do not think there can be any
>> changes even after avoiding overlapping tunnel types in given socket.
>
> I guess I'm not sure why with the later changes it would be
> incompatible. All I'm talking about is something pretty small:
>
> geneve_open:
>         if (geneve->collect_md)
>                 gs->collect_md = true;
> to
>                 gs->collect_md = geneve->collect_md;
>
> geneve_close:
> remove
>         if (geneve->collect_md)
>                 gs->collect_md = false;
> since the socket is about to be freed anyways.
>
> It's not very different in practice but it looks less like refcounting
> and more like a 1:1 mapping.

ok, I thought you were talking about socket refcounting. I will make
the changes.

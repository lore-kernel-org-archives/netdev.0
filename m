From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Long stalls creating a new netns after a netns with a SMB client exits
Date: Mon, 31 Jul 2017 10:06:41 -0700
Message-ID: <CAM_iQpWascP6-6x824S60q1WUcLPBgjKrDh+hhyz7EjhYY=q7Q@mail.gmail.com>
References: <CA+pO-2cm7bz861KvPMpugP8rVwf6rU8QYrVq7PVO-ZXx2kh1fw@mail.gmail.com>
 <CAM_iQpW+gSgCDWdGoHvN0wObda_g40FcyCBem5VVJ4XLHNMRaQ@mail.gmail.com> <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36752 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdGaRHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 13:07:03 -0400
Received: by mail-wm0-f53.google.com with SMTP id t201so185287452wmt.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 10:07:02 -0700 (PDT)
In-Reply-To: <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 11:58 AM, Rolf Neugebauer
<rolf.neugebauer@docker.com> wrote:
> On Fri, Jul 28, 2017 at 6:49 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Hello,
>>
>> On Fri, Jul 28, 2017 at 9:47 AM, Rolf Neugebauer
>> <rolf.neugebauer@docker.com> wrote:
>>> Creating the new namespace is stalling for around 200 seconds and
>>> there 20 odd messages on the console, like:
>>>
>>> [   67.372603] unregister_netdevice: waiting for lo to become free.
>>> Usage count = 1
>>>
>>
>> Sounds like another netdev refcnt leak.
>
> I don't think it's a leak as such because the system eventually
> recovers after around 200 seconds.
>
>>
>>> Adding a 'sleep 1' before deleting the original network namespace
>>> "solves" the issue, but that doesn't sound like a good fix. Not using
>>> unmount also does not help (understandable).
>>
>>
>> Interesting, if sleeping for 1sec help, why did you see the stall for
>> 200sec? The "leak" should go away eventually without 'sleep 1',
>> right?
>
> Yes. I suspect, that with a sleep some cleanup code (maybe umount)
> gets run and the ref count gets decremented within the second. Without
> the sleep, something gets yanked, and whatever operation needs to be
> done can't get performed, times out after 200s and then the ref count
> gets decremented.


This reminds me of

commit f186ce61bb8235d80068c390dc2aad7ca427a4c2
Author: Krister Johansen <kjlx@templeofstupid.com>
Date:   Thu Jun 8 13:12:38 2017 -0700

    Fix an intermittent pr_emerg warning about lo becoming free.

but this one is merged in 4.12 too, so must be something else.

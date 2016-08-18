From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Fri, 19 Aug 2016 06:53:49 +0800
Message-ID: <CA+6hz4r_062yftgqhXBzQJKsfQ8RLukmMp1f4oYPcbP6XSy+uQ@mail.gmail.com>
References: <1471345503-10085-1-git-send-email-fgao@ikuai8.com>
 <CA+6hz4qN-UmSutpCOY1KtrPBakh+2Qa+VUNVid7dq7EPWZE+aw@mail.gmail.com>
 <96f03d73-73f9-23ac-591f-a855169f8dc9@redfish-solutions.com>
 <CA+6hz4rUGeqohKCiTbeqp9NwkH5w_JKjqD8VEiQC4DyVL7Q7JA@mail.gmail.com> <fcdca34b-cfbb-4536-b857-843218645b82@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@48lvckh6395k16k5.yundunddos.com>, paulus@samba.org,
        linux-ppp@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Philp Prindeville <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:35081 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754956AbcHSBQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:16:50 -0400
In-Reply-To: <fcdca34b-cfbb-4536-b857-843218645b82@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Philp,

Yes. I am agree with you.
Just drop is better to support recursive lock.

I will send a new patch later.

Regards
Feng


On Fri, Aug 19, 2016 at 12:48 AM, Philp Prindeville
<philipp@redfish-solutions.com> wrote:
>
>
> On 08/18/2016 09:05 AM, Feng Gao wrote:
>>
>> On Thu, Aug 18, 2016 at 10:11 PM, Philp Prindeville
>> <philipp@redfish-solutions.com>  wrote:
>>>
>>> >Feng,
>>> >
>>> >If the CPU can already be holding the lock, that implies re-entrancy.
>>> >What's to stop the first flow of code which acquired the lock from
>>> > releasing
>>> >it again before the 2nd flow is done?  Is the 2nd flow running at a
>>> > higher
>>> >priority or with interrupts disabled?
>>
>> There is no preemption happened. It is caused by wrong route policy by
>> l2tp.
>> For example, the cpu0 get the spinlock of channel1, then the channel1
>> is selected again after route. As a result, cpu0 tries to get the same
>> spinlock again.
>>
>> The call flow is like this.
>> ppp_write->ppp_channel_push->start_xmit->select inappropriate route
>> .... -> dev_hard_start_xmit->ppp_start_xmit->ppp_xmit_process->
>> ppp_push. Now ppp_push tries to get the same spinlock which is held
>> in ppp_channel_push.
>>
>> Regards
>> Feng
>>
>
> If we're detecting (through the fact that the lock has already been
> acquired) that the wrong route is being applied, why don't we just punt the
> packet instead?
>
> -Philip
>

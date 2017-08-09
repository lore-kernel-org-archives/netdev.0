From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Qdisc->u32_node - licence to kill
Date: Wed, 9 Aug 2017 08:40:30 -0400
Message-ID: <c296f4c2-3509-a162-e972-42c2e81434aa@mojatatu.com>
References: <20170807164100.GK2085@nanopsycho.orion>
 <5988A7A2.3090200@gmail.com> <20170807190624.GL2085@nanopsycho.orion>
 <5988C55B.60204@gmail.com>
 <CAM_iQpUZdv1sg+6jY862=GbWaC8x9XN9Ed-uaKi6_RT12sFj6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35609 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751523AbdHIMkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:40:33 -0400
Received: by mail-it0-f65.google.com with SMTP id 76so4441439ith.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:40:32 -0700 (PDT)
In-Reply-To: <CAM_iQpUZdv1sg+6jY862=GbWaC8x9XN9Ed-uaKi6_RT12sFj6w@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-07 07:21 PM, Cong Wang wrote:
> On Mon, Aug 7, 2017 at 12:54 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> On 08/07/2017 12:06 PM, Jiri Pirko wrote:
>>> Mon, Aug 07, 2017 at 07:47:14PM CEST, john.fastabend@gmail.com wrote:
>>>> On 08/07/2017 09:41 AM, Jiri Pirko wrote:
>>>>> Hi Jamal/Cong/David/all.
>>>>>
=
>>>
>>> Not correct. prio/pref is one level up priority, independent on specific
>>> cls implementation. You can have cls_u32 instance on prio 10 and
>>> cls_flower instance on prio 20. Both work.
>>
>> ah right, lets make sure I got this right then (its been awhile since I've
>> read this code). So the tcf_ctl_tfilter hook walks classifiers, inserting the
>> classifier by prio. Then tcf_classify walks the list of classifiers looking
>> for any matches, specifically any return codes it recognizes or a return code
>> greater than zero. u32 though has this link notion that allows users to jump
>> to other u32 classifiers that are in this list, because it has a global hash
>> table list. So the per prio classifier isolation is not true in u32 case.
> 
> u32 filter supports multiple hash tables within a qdisc, struct
> tc_u_common is supposed to link them together. This has to be
> per qdisc because all of these hash tables belong to one qdisc
> and their ID's are unique within the qdisc.
> 

I think historically this used to sit within the u32 code as a
static linked list; i cant recall why it got attached to the
qdisc.
Indeed, the idea is that hash tables can be added independently
without linking and then linked afterwards. They have to be held
somewhere in transient. And they have priorities (at least the
prios are used in the dump)

> I dislike it too, and I actually tried to improve it in the past,
> unfortunately didn't make any real progress. I think we can
> definitely make it less ugly, but I don't think we can totally
> get rid of it because of the design of u32.
> 
> Similar for tp->data.
> 

tp->q maybe harder to deal with. I agree with getting rid of
this dependency. Could this info be stored in the block instead?

cheers,
jamal

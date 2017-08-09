From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Qdisc->u32_node - licence to kill
Date: Wed, 9 Aug 2017 14:48:34 +0200
Message-ID: <20170809124834.GC1867@nanopsycho>
References: <20170807164100.GK2085@nanopsycho.orion>
 <5988A7A2.3090200@gmail.com>
 <20170807190624.GL2085@nanopsycho.orion>
 <5988C55B.60204@gmail.com>
 <CAM_iQpUZdv1sg+6jY862=GbWaC8x9XN9Ed-uaKi6_RT12sFj6w@mail.gmail.com>
 <c296f4c2-3509-a162-e972-42c2e81434aa@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34901 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751987AbdHIMsg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:48:36 -0400
Received: by mail-wm0-f48.google.com with SMTP id m85so30988686wma.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:48:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c296f4c2-3509-a162-e972-42c2e81434aa@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 09, 2017 at 02:40:30PM CEST, jhs@mojatatu.com wrote:
>On 17-08-07 07:21 PM, Cong Wang wrote:
>> On Mon, Aug 7, 2017 at 12:54 PM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>> > On 08/07/2017 12:06 PM, Jiri Pirko wrote:
>> > > Mon, Aug 07, 2017 at 07:47:14PM CEST, john.fastabend@gmail.com wrote:
>> > > > On 08/07/2017 09:41 AM, Jiri Pirko wrote:
>> > > > > Hi Jamal/Cong/David/all.
>> > > > > 
>=
>> > > 
>> > > Not correct. prio/pref is one level up priority, independent on specific
>> > > cls implementation. You can have cls_u32 instance on prio 10 and
>> > > cls_flower instance on prio 20. Both work.
>> > 
>> > ah right, lets make sure I got this right then (its been awhile since I've
>> > read this code). So the tcf_ctl_tfilter hook walks classifiers, inserting the
>> > classifier by prio. Then tcf_classify walks the list of classifiers looking
>> > for any matches, specifically any return codes it recognizes or a return code
>> > greater than zero. u32 though has this link notion that allows users to jump
>> > to other u32 classifiers that are in this list, because it has a global hash
>> > table list. So the per prio classifier isolation is not true in u32 case.
>> 
>> u32 filter supports multiple hash tables within a qdisc, struct
>> tc_u_common is supposed to link them together. This has to be
>> per qdisc because all of these hash tables belong to one qdisc
>> and their ID's are unique within the qdisc.
>> 
>
>I think historically this used to sit within the u32 code as a
>static linked list; i cant recall why it got attached to the
>qdisc.
>Indeed, the idea is that hash tables can be added independently
>without linking and then linked afterwards. They have to be held
>somewhere in transient. And they have priorities (at least the
>prios are used in the dump)
>
>> I dislike it too, and I actually tried to improve it in the past,
>> unfortunately didn't make any real progress. I think we can
>> definitely make it less ugly, but I don't think we can totally
>> get rid of it because of the design of u32.
>> 
>> Similar for tp->data.
>> 
>
>tp->q maybe harder to deal with. I agree with getting rid of
>this dependency. Could this info be stored in the block instead?

Yeah, I will have to do that. I just wanted to get rid of it if possible :/


>
>cheers,
>jamal

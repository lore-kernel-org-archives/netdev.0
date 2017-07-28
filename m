From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Thu, 27 Jul 2017 21:56:08 -0700
Message-ID: <CAM_iQpU5EZr1rtgY8sCBjD=utzmi9c6MQ2xb36iXLk++qSk3WA@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com> <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com> <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com> <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com> <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34149 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdG1E43 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 00:56:29 -0400
Received: by mail-wm0-f66.google.com with SMTP id x64so1664237wmg.1
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 21:56:29 -0700 (PDT)
In-Reply-To: <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 11:49 AM, David Ahern <dsahern@gmail.com> wrote:
> On 7/26/17 12:27 PM, Roopa Prabhu wrote:
>> agreed...so looks like the check in v3 should be
>>
>>
>> +       if ( rt == net->ipv6.ip6_null_entry ||
>> +            (rt->dst.error &&
>> + #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>> +              rt != net->ipv6.ip6_prohibit_entry &&
>> +              rt != net->ipv6.ip6_blk_hole_entry &&
>> +#endif
>> +             )) {
>>                 err = rt->dst.error;
>>                 ip6_rt_put(rt);
>>                 goto errout;
>>
>
> I don't think so. If I add a prohibit route and use the fibmatch
> attribute, I want to see the route from the FIB that was matched.

But net->ipv6.ip6_prohibit_entry is not the prohibit route you can
add in user-space, it is only used by rule actions. So do you really
want to dump it?? My gut feeling is no, but I am definitely not sure.

When you add a prohibit route, a new rt is allocated dynamically,
net->ipv6.ip6_prohibit_entry is relatively static, internal and is the
only one per netns. (Same for net->ipv6.ip6_blk_hole_entry)

I think Hangbin's example doesn't have ip rules, so this case
is not shown up.

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Wed, 26 Jul 2017 11:55:51 -0700
Message-ID: <CAJieiUi+Me_wXDz0A1oLH2LgBw9DsMoxctV56SjEwGpusFGt4Q@mail.gmail.com>
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
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:34089 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdGZSzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:55:53 -0400
Received: by mail-ua0-f181.google.com with SMTP id q25so105178200uah.1
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:55:53 -0700 (PDT)
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


yes, exactly. wouldn't  'rt != net->ipv6.ip6_prohibit_entry' above let
it fall through to the route fill code ?

ah...but i guess you are saying that they will have rt6_info's of
their own and will not match. got it. ack.

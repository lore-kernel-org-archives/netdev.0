From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Wed, 26 Jul 2017 11:18:10 -0600
Message-ID: <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37101 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751103AbdGZRSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 13:18:12 -0400
Received: by mail-pf0-f194.google.com with SMTP id y25so8559974pfk.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 10:18:12 -0700 (PDT)
In-Reply-To: <20170725073202.GE2938@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/25/17 1:32 AM, Hangbin Liu wrote:
> On Mon, Jul 24, 2017 at 09:28:07PM -0600, David Ahern wrote:
>> On 7/24/17 6:08 PM, Hangbin Liu wrote:
>>> That's why I think we should remove both rt->dst.error and ip6_null_entry
>>> check in inet6_rtm_getroute(). And even further, remove the ip6_null_entry
>>> check in rt6_dump_route().
>>
>> git blame net/ipv6/route.c
>>
>> find the commits and review.
> 
> Hi David,
> 
> Sorry, would you like to give me more hints?
> 
> I saw your commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route
> dumps"). But I think this issue has been fixed by
> 
> 2f460933f58e ("ipv6: initialize route null entry in addrconf_init()") and
> 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
> 
> I use a reproducer which add unreachable route in netns with lo down. And I
> could not trigger Panic in the fixed kernel. That's why I think we could
> remove ip6_null_entry check in rt6_dump_route().

Understood. Cong's patch to fix the intialization order (lo device
before route init) makes sure the idev is not null. That said, the
null_entry route is internal ipv6 logic and is not a route entry to be
returned to userspace.

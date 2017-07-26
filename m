From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Wed, 26 Jul 2017 17:18:53 +0800
Message-ID: <20170726091853.GB5465@leo.usersys.redhat.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <CAM_iQpXvyZR6EZ8s_P6JcKZhHN9t5N+2s4cTqHy0RLdGEMeg0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsahern@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36027 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdGZJTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 05:19:05 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so16851243pgy.3
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 02:19:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXvyZR6EZ8s_P6JcKZhHN9t5N+2s4cTqHy0RLdGEMeg0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 10:49:05AM -0700, Cong Wang wrote:
> On Mon, Jul 24, 2017 at 5:08 PM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> > But what we want in inet6_rtm_getroute() and rt6_dump_route() is to
> > get/dump the route info. So we should get the info even it's unreachable or
> > prohibit.
> 
> If you want to dump prohibit/blackhole entry, then you have to check
> for null_entry, and rt->dst.error check is still needed because we

I could not reproduce the NULL rt6i_idev issue after you route init fix, So
I think it's also safe to dump null_entry now. There is a v3 patch. After
the patch, we could dump unreachable route info like:

+ ip netns exec client ip -6 route get 2003::1
unreachable 2003::1 dev lo table unspec proto kernel metric 4294967295 error -101

> could return error on other normal entries too, IOW, your v2 is correct
> if dumping prohibit/blackhole is expected.

Would you hlep review the v3 patch? I prepare not touch the check in
function rt6_dump_route() now.

Thanks
Hangbin

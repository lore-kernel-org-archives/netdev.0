From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Tue, 25 Jul 2017 08:08:49 +0800
Message-ID: <20170725000849.GD2938@leo.usersys.redhat.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33877 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754449AbdGYAJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:09:00 -0400
Received: by mail-pg0-f66.google.com with SMTP id v190so13018659pgv.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 17:09:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 12:57:43PM -0700, Cong Wang wrote:
> On Sun, Jul 23, 2017 at 8:09 PM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> > Do we still need this net->ipv6.ip6_null_entry check? How about remove all
> > the checks?
> 
> I believe you only need to check for rt->dst.error, no need to check against
> NULL or ip6_null_entry.
> 
> Take a look at other ip6_route_lookup() callers.

Yes, I saw it. That why I send v2 patch to check both rt->dst.error and
ip6_null_entry.

The question is the other two caller are rpfilter_lookup_reverse6() and
nft_fib6_eval(). From the code it looks these two caller only care about
device match.

         if (rt->rt6i_idev->dev == dev || (flags & XT_RPFILTER_LOOSE))
                 ret = true;

And the device would be lo if it is ip6_null_entry. So they just discard it.
I'm not familiar with netfilter, Please correct me if I make any mistake.

But what we want in inet6_rtm_getroute() and rt6_dump_route() is to
get/dump the route info. So we should get the info even it's unreachable or
prohibit.

That's why I think we should remove both rt->dst.error and ip6_null_entry
check in inet6_rtm_getroute(). And even further, remove the ip6_null_entry
check in rt6_dump_route().

What do you think?

Thanks
Hangbin

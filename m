From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Tue, 25 Jul 2017 15:32:02 +0800
Message-ID: <20170725073202.GE2938@leo.usersys.redhat.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35222 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750769AbdGYHcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 03:32:13 -0400
Received: by mail-pg0-f65.google.com with SMTP id d193so13797454pgc.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 00:32:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 09:28:07PM -0600, David Ahern wrote:
> On 7/24/17 6:08 PM, Hangbin Liu wrote:
> > That's why I think we should remove both rt->dst.error and ip6_null_entry
> > check in inet6_rtm_getroute(). And even further, remove the ip6_null_entry
> > check in rt6_dump_route().
> 
> git blame net/ipv6/route.c
> 
> find the commits and review.

Hi David,

Sorry, would you like to give me more hints?

I saw your commit 1f17e2f2c8a8 ("net: ipv6: ignore null_entry on route
dumps"). But I think this issue has been fixed by

2f460933f58e ("ipv6: initialize route null entry in addrconf_init()") and
242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")

I use a reproducer which add unreachable route in netns with lo down. And I
could not trigger Panic in the fixed kernel. That's why I think we could
remove ip6_null_entry check in rt6_dump_route().

Please correct me if I make any mistake.

Thanks
Hangbin

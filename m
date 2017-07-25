From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Tue, 25 Jul 2017 10:49:05 -0700
Message-ID: <CAM_iQpXvyZR6EZ8s_P6JcKZhHN9t5N+2s4cTqHy0RLdGEMeg0A@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com> <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37389 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdGYRt1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:49:27 -0400
Received: by mail-wm0-f43.google.com with SMTP id c184so62586832wmd.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 10:49:26 -0700 (PDT)
In-Reply-To: <20170725000849.GD2938@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 5:08 PM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> But what we want in inet6_rtm_getroute() and rt6_dump_route() is to
> get/dump the route info. So we should get the info even it's unreachable or
> prohibit.


If you want to dump prohibit/blackhole entry, then you have to check
for null_entry, and rt->dst.error check is still needed because we
could return error on other normal entries too, IOW, your v2 is correct
if dumping prohibit/blackhole is expected.

I thought we don't dump them. I am not sure about the behavior either.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net,v2] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Tue, 20 Jun 2017 11:45:10 -0700
Message-ID: <CAM_iQpWk_mno_RjieO4UMZVXtudX7sSvxQLUNLF4OpEejuRtOg@mail.gmail.com>
References: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com>
 <59489369.8000309@rock-chips.com> <CAM_iQpWN6qFsQ_oAMXjC7k00pf0j90zxdx6hzUS58MFn29QSbg@mail.gmail.com>
 <5948C290.6050409@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        David Ahern <dsahern@gmail.com>,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>
To: jeffy <jeffy.chen@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:34236 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdFTSpc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 14:45:32 -0400
Received: by mail-wr0-f180.google.com with SMTP id 77so102817517wrb.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 11:45:31 -0700 (PDT)
In-Reply-To: <5948C290.6050409@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 19, 2017 at 11:37 PM, jeffy <jeffy.chen@rock-chips.com> wrote:
> Hi Cong Wang,
>
>
> On 06/20/2017 12:54 PM, Cong Wang wrote:
>>
>> Interesting, I didn't notice this corner-case, because normally
>> we would hit the one in rollback_registered_many(). Probably
>> we need to add a check
>>
>> if (dev->reg_state == NETREG_UNREGISTERING)
>>
>> in ip6_route_dev_notify(). Can you give it a try?
>
> the NETREG_UNREGISTERING check works for my test:)
>
> but i saw dev_change_net_namespace also call NETDEV_UNREGISTER &
> NETDEV_REGISTER:

Yes we should call it in this case too, only netdev_wait_allrefs()
is an exceptional case here.

I just sent out a formal patch with you Cc'ed.

Thanks!

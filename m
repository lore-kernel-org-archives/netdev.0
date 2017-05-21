From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] geneve: always fill CSUM6_RX configuration
Date: Sat, 20 May 2017 21:56:44 -0700
Message-ID: <CAOrHB_BnX9P9ONLvZcBj+M2_ZbOyGqtu+nYNuP5XBtJc2yUfMw@mail.gmail.com>
References: <20170518195956.12686-1-e@erig.me> <CAOrHB_CKLgriV3XjG1fBHvyB9GQQ3GXOT8+ggmtLXFz3cvj56Q@mail.gmail.com>
 <20170520133503.GM9969@rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Eric Garver <e@erig.me>, Pravin Shelar <pshelar@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:40188 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdEUE4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 00:56:48 -0400
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id AA10FC5A5A
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 06:56:46 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id umZpKZI4kCwT for <netdev@vger.kernel.org>;
        Sun, 21 May 2017 06:56:45 +0200 (CEST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id F29D5C5A51
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 06:56:44 +0200 (CEST)
Received: by mail-wm0-f46.google.com with SMTP id b84so264552053wmh.0
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 21:56:44 -0700 (PDT)
In-Reply-To: <20170520133503.GM9969@rhel7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 6:35 AM, Eric Garver <e@erig.me> wrote:
> On Fri, May 19, 2017 at 06:57:46PM -0700, Pravin Shelar wrote:
>> On Thu, May 18, 2017 at 12:59 PM, Eric Garver <e@erig.me> wrote:
>> > CSMU6_RX is relevant for collect_metadata as well. As such leave it
>> > outside of the dev's IPv4/IPv6 checks.
>> >
>> Can you explain it bit? is this flag used with ipv4 tunnels?
>
> It's used with collect_metadata as both ipv4 and ipv6 sockets will be
> created.
>
> openvswitch recently gained support for creating tunnels with rtnetlink.
> It sets COLLECT_METADATA and CSUM6_RX. After create, it does a get to
> verify the device got created with all the requested configuration. The
> verify was failing due to CSUM6_RX not being returned.
>
> Since ip_tunnel_info_af() defaults to returning AF_INET, we fall into
> the IPv4 case and CSUM6_RX is never returned. Other relevant areas that
> call ip_tunnel_info_af() do so using the info from the skb, not the
> geneve_dev.
>
ok.
I think ip_tunnel_info_af() check is not right. it does not work in
case of collect_metadata.
Better fix would be check for genene->sock4 and genene->sock6 and
build the netlink skb accordingly.

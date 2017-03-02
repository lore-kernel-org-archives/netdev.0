From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Thu, 2 Mar 2017 12:11:29 -0800
Message-ID: <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com>
References: <20170302103219.74b675c5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        chenweilong@huawei.com, dan@polter.net,
        Jiri Pirko <jiri@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:35212 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751262AbdCBUVK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 15:21:10 -0500
Received: by mail-wr0-f178.google.com with SMTP id g10so60670841wrg.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 12:21:09 -0800 (PST)
In-Reply-To: <20170302103219.74b675c5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 2, 2017 at 10:32 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Wed, 01 Mar 2017 21:08:01 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: stephen@networkplumber.org
> Subject: [Bug 194749] New: kernel bonding does not work in a network nameservice in versions above 3.10.0-229.20.1
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=194749
>
>             Bug ID: 194749
>            Summary: kernel bonding does not work in a network nameservice
>                     in versions above 3.10.0-229.20.1
>            Product: Networking
>            Version: 2.5
>     Kernel Version: > 3.10.0-229.20.1
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>           Assignee: stephen@networkplumber.org
>           Reporter: dan@polter.net
>         Regression: No
>
> bond interface is being used in active/standby mode with two physical NICs
> inside a network nameservice to provide switchpath redundancy.
>
> netns is instantiated post-boot with the following:
>
> ip netns add vntp
> ip link set p4p1 netns vntp
> ip link set p4p2 netns vntp
> ip link set bond0 netns vntp
> ip netns exec vntp ip link set lo up
> ip netns exec vntp ip link set p4p1 up
> ip netns exec vntp ip link set p4p2 up
> ip netns exec vntp ip link set bond0 up
> ip netns exec vntp ifenslave bond0 p4p1 p4p2

This is due to the following commit:

commit f9399814927ad9bb995a6e109c2a5f9d8a848209
Author: Weilong Chen <chenweilong@huawei.com>
Date:   Wed Jan 22 17:16:30 2014 +0800

    bonding: Don't allow bond devices to change network namespaces.

    Like bridge, bonding as netdevice doesn't cross netns boundaries.

    Bonding ports and bonding itself live in same netns.

    Signed-off-by: Weilong Chen <chenweilong@huawei.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


NETIF_F_NETNS_LOCAL was introduced for loopback device which
is created for each netns, it is not clear why we need to add it to bond
and bridge...

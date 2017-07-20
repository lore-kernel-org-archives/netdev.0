From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: check mac address length for dev_set_mac_address()
Date: Thu, 20 Jul 2017 16:39:53 -0700
Message-ID: <CAM_iQpUYmTTMcb1tU=nxTAwgPS=6TZYQKPqU6xgo09hakxB32Q@mail.gmail.com>
References: <20170720182758.20204-1-xiyou.wangcong@gmail.com> <20170720182758.20204-2-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Ahern <dsahern@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37498 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964894AbdGTXkP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 19:40:15 -0400
Received: by mail-wm0-f66.google.com with SMTP id m4so5199861wmi.4
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 16:40:14 -0700 (PDT)
In-Reply-To: <20170720182758.20204-2-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 11:27 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> dev_set_mac_address() accepts a struct sockaddr pointer as
> input but we have various types of mac addresse whose lengths
> are up to MAX_ADDR_LEN, this is confusing.
>
> Make it void like ->ndo_set_mac_address() and let callers check
> its length before calling it. It is too late to fix dev_ifsioc()
> due to API compatibility, so just reject those larger than
> sizeof(struct sockaddr).
>
> Fortunately, only a few IPv6 tunnel devices have addr_len
> larger than sizeof(struct sockaddr) and they don't support
> ndo_set_mac_addr(). But team driver seems still buggy without
> this patch.

Note, in team lb mode, I can successfully enslave ip6gre device
to a team device and make its mac addr look like:

# ip li show dev team0
17: team0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1448 qdisc noqueue
state UP mode DEFAULT group default qlen 1000
    link/gre6 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd
00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00

But ifconfig seems not recognize gre6 family, so it is just a matter of
a few lines of C code to trigger the bug.

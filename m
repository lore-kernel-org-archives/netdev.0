From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next RFC 0/4] Openvswitch meter action
Date: Fri, 13 Oct 2017 17:09:56 -0700
Message-ID: <CAOrHB_DcgWphWiuN0hP3ej66zKbtRsrxU0wvVH0toRZCN4LVbg@mail.gmail.com>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, Greg Rose <gvrose8192@gmail.com>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:35114 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752769AbdJNAJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 20:09:58 -0400
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 8CC39FB881
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 02:09:57 +0200 (CEST)
Received: by mail-wm0-f45.google.com with SMTP id q124so24138629wmb.0
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 17:09:57 -0700 (PDT)
In-Reply-To: <1507847923-13612-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 3:38 PM, Andy Zhou <azhou@ovn.org> wrote:
> This patch series is the first attempt to add openvswitch
> meter support. We have previously experimented with adding
> metering support in nftables. However 1) It was not clear
> how to expose a named nftables object cleanly, and 2)
> the logic that implements metering is quite small, < 100 lines
> of code.
>
> With those two observations, it seems cleaner to add meter
> support in the openvswitch module directly.
>
>
Thanks for working on this feature. It looks good to me. I have couple
of comments inlined.

> Andy Zhou (4):
>   openvswitch: Add meter netlink definitions
>   openvswitch: export get_dp() API.
>   openvswitch: Add meter infrastructure
>   openvswitch: Add meter action support
>
>  include/uapi/linux/openvswitch.h |  52 ++++
>  net/openvswitch/Makefile         |   1 +
>  net/openvswitch/actions.c        |  12 +
>  net/openvswitch/datapath.c       |  43 +--
>  net/openvswitch/datapath.h       |  35 +++
>  net/openvswitch/flow_netlink.c   |   6 +
>  net/openvswitch/meter.c          | 611 +++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/meter.h          |  54 ++++
>  8 files changed, 783 insertions(+), 31 deletions(-)
>  create mode 100644 net/openvswitch/meter.c
>  create mode 100644 net/openvswitch/meter.h
>
> --
> 1.8.3.1
>

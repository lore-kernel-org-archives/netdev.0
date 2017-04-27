From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 00/10] net: sched: introduce multichain support
 for filters
Date: Thu, 27 Apr 2017 10:46:03 -0700
Message-ID: <CAM_iQpXUs1301-OR1_bsO-0bU8sSBVo2BWRHy4qNhzdHxvJWaQ@mail.gmail.com>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        mlxsw@mellanox.com, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33022 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163876AbdD0RqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 13:46:25 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so6178583wmh.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 10:46:24 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Simple example:
> $ tc qdisc add dev eth0 ingress
> $ tc filter add dev eth0 parent ffff: protocol ip pref 33 flower dst_mac 52:54:00:3d:c7:6d action goto chain 11
> $ tc filter add dev eth0 parent ffff: protocol ip pref 22 chain 11 flower dst_ip 192.168.40.1 action drop
> $ tc filter show dev eth0 root

Interesting.

I don't look into the code yet. If I understand the concepts correctly,
so with your patchset we can mark either filter with a chain No. to
choose which chain it belongs to _logically_ even though
_physically_ it is still in the old-fashion chain (prio, proto)?

If so, you have to ensure proto is same since the protocol of
the packet does not change dynamically? And the original
priority becomes pointless with chains since we can just to
any other chain in any order?

By default, without any chain No., you use 0 for all the chains,
so the old-fashion chain still works.

Thanks.

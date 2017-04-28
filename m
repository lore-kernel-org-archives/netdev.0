From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/10] net: sched: introduce multichain support
 for filters
Date: Fri, 28 Apr 2017 08:53:49 +0200
Message-ID: <20170428065349.GB1886@nanopsycho.orion>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <CAM_iQpXUs1301-OR1_bsO-0bU8sSBVo2BWRHy4qNhzdHxvJWaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        mlxsw@mellanox.com, Simon Horman <simon.horman@netronome.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36617 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424096AbdD1Gxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 02:53:53 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so6025503wrc.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 23:53:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXUs1301-OR1_bsO-0bU8sSBVo2BWRHy4qNhzdHxvJWaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 27, 2017 at 07:46:03PM CEST, xiyou.wangcong@gmail.com wrote:
>On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Simple example:
>> $ tc qdisc add dev eth0 ingress
>> $ tc filter add dev eth0 parent ffff: protocol ip pref 33 flower dst_mac 52:54:00:3d:c7:6d action goto chain 11
>> $ tc filter add dev eth0 parent ffff: protocol ip pref 22 chain 11 flower dst_ip 192.168.40.1 action drop
>> $ tc filter show dev eth0 root
>
>Interesting.
>
>I don't look into the code yet. If I understand the concepts correctly,
>so with your patchset we can mark either filter with a chain No. to
>choose which chain it belongs to _logically_ even though
>_physically_ it is still in the old-fashion chain (prio, proto)?

You have to see the code :)

There are physically multiple chains


>
>If so, you have to ensure proto is same since the protocol of
>the packet does not change dynamically? And the original
>priority becomes pointless with chains since we can just to
>any other chain in any order?
>
>By default, without any chain No., you use 0 for all the chains,
>so the old-fashion chain still works.

Yes.

>
>Thanks.

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 00/10] net: sched: introduce multichain support
 for filters
Date: Fri, 28 Apr 2017 10:40:24 -0700
Message-ID: <CAM_iQpXU0nKUMg3CqE=UOZ5R=mkxSAEFANObGt6+vKEeyXXXZg@mail.gmail.com>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <CAM_iQpXUs1301-OR1_bsO-0bU8sSBVo2BWRHy4qNhzdHxvJWaQ@mail.gmail.com> <20170428065349.GB1886@nanopsycho.orion>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33894 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642175AbdD1Rkq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 13:40:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id z129so12322405wmb.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 10:40:45 -0700 (PDT)
In-Reply-To: <20170428065349.GB1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 11:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Apr 27, 2017 at 07:46:03PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Simple example:
>>> $ tc qdisc add dev eth0 ingress
>>> $ tc filter add dev eth0 parent ffff: protocol ip pref 33 flower dst_mac 52:54:00:3d:c7:6d action goto chain 11
>>> $ tc filter add dev eth0 parent ffff: protocol ip pref 22 chain 11 flower dst_ip 192.168.40.1 action drop
>>> $ tc filter show dev eth0 root
>>
>>Interesting.
>>
>>I don't look into the code yet. If I understand the concepts correctly,
>>so with your patchset we can mark either filter with a chain No. to
>>choose which chain it belongs to _logically_ even though
>>_physically_ it is still in the old-fashion chain (prio, proto)?
>
> You have to see the code :)

I don't understand why I have to, these are high-level concepts
and should be put in your cover letter (aka. design doc). You miss
a lot of information about the ordering here.

Also the terms you use are confusing too, without your patchset
we have chains too, struct tcf_proto is a chain, each kind of filter
defines their own way to store their filters into this chain (tp->root),
and of course tp is chained in a singly-linked list too which turns
into multiple-chains.

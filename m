From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 02/10] net: sched: introduce tcf block infractructure
Date: Fri, 28 Apr 2017 10:48:34 -0700
Message-ID: <CAM_iQpV8gN8SR_QsT5pLef9PL=ArHXrnceutFZbJzEhFPBJFeQ@mail.gmail.com>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us> <1493291540-2119-3-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35032 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642168AbdD1Rs4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 13:48:56 -0400
Received: by mail-wm0-f68.google.com with SMTP id d79so12354990wmi.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 10:48:55 -0700 (PDT)
In-Reply-To: <1493291540-2119-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Currently, the filter chains are direcly put into the private structures
> of qdiscs. In order to be able to have multiple chains per qdisc and to
> allow filter chains sharing among qdiscs, there is a need for common
> object that would hold the chains. This introduces such object and calls
> it "tcf_block".
>

What is filter chains sharing here? Sounds like a new feature you are
trying to hide? How could it be possibly shared among qdisc's when they
are still stored in a per-qdisc pointer?

Look at tc actions, they can be shared because they are physically stored
in a per-netns hashtable, filters can just refer them with indexes.

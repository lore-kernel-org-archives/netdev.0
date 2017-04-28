From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 02/10] net: sched: introduce tcf block
 infractructure
Date: Sat, 29 Apr 2017 00:29:28 +0200
Message-ID: <20170428222928.GA1905@nanopsycho.orion>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <1493291540-2119-3-git-send-email-jiri@resnulli.us>
 <CAM_iQpV8gN8SR_QsT5pLef9PL=ArHXrnceutFZbJzEhFPBJFeQ@mail.gmail.com>
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
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35271 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2997379AbdD1W3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 18:29:32 -0400
Received: by mail-wr0-f195.google.com with SMTP id g12so8384494wrg.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 15:29:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpV8gN8SR_QsT5pLef9PL=ArHXrnceutFZbJzEhFPBJFeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 07:48:34PM CEST, xiyou.wangcong@gmail.com wrote:
>On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Currently, the filter chains are direcly put into the private structures
>> of qdiscs. In order to be able to have multiple chains per qdisc and to
>> allow filter chains sharing among qdiscs, there is a need for common
>> object that would hold the chains. This introduces such object and calls
>> it "tcf_block".
>>
>
>What is filter chains sharing here? Sounds like a new feature you are
>trying to hide? How could it be possibly shared among qdisc's when they
>are still stored in a per-qdisc pointer?

I can change the description. I just found out that eventually, later
on, the blocks could be shared among qdiscs. It is not part of this
patchset. Just this change of infra is bringing this one step closer.

I can imagine that the blocks could have indexes and when you create a
qdisc you could pass this index of an existing block.

Not trying to hide anything!


>
>Look at tc actions, they can be shared because they are physically stored
>in a per-netns hashtable, filters can just refer them with indexes.

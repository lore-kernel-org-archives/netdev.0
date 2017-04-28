From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/10] net: sched: introduce multichain support
 for filters
Date: Sat, 29 Apr 2017 00:34:46 +0200
Message-ID: <20170428223446.GB1905@nanopsycho.orion>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <CAM_iQpXUs1301-OR1_bsO-0bU8sSBVo2BWRHy4qNhzdHxvJWaQ@mail.gmail.com>
 <20170428065349.GB1886@nanopsycho.orion>
 <CAM_iQpXU0nKUMg3CqE=UOZ5R=mkxSAEFANObGt6+vKEeyXXXZg@mail.gmail.com>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34757 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999733AbdD1Wet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 18:34:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id z129so13482727wmb.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 15:34:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpXU0nKUMg3CqE=UOZ5R=mkxSAEFANObGt6+vKEeyXXXZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 28, 2017 at 07:40:24PM CEST, xiyou.wangcong@gmail.com wrote:
>On Thu, Apr 27, 2017 at 11:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Apr 27, 2017 at 07:46:03PM CEST, xiyou.wangcong@gmail.com wrote:
>>>On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Simple example:
>>>> $ tc qdisc add dev eth0 ingress
>>>> $ tc filter add dev eth0 parent ffff: protocol ip pref 33 flower dst_mac 52:54:00:3d:c7:6d action goto chain 11
>>>> $ tc filter add dev eth0 parent ffff: protocol ip pref 22 chain 11 flower dst_ip 192.168.40.1 action drop
>>>> $ tc filter show dev eth0 root
>>>
>>>Interesting.
>>>
>>>I don't look into the code yet. If I understand the concepts correctly,
>>>so with your patchset we can mark either filter with a chain No. to
>>>choose which chain it belongs to _logically_ even though
>>>_physically_ it is still in the old-fashion chain (prio, proto)?
>>
>> You have to see the code :)
>
>I don't understand why I have to, these are high-level concepts
>and should be put in your cover letter (aka. design doc). You miss
>a lot of information about the ordering here.

Well, the description is one thing, but seeing the actual code should
put the whole view. But if you are missing something, I can add it. What
do you mean by "information about the ordering"?


>
>Also the terms you use are confusing too, without your patchset
>we have chains too, struct tcf_proto is a chain, each kind of filter
>defines their own way to store their filters into this chain (tp->root),
	 
Those are internal structures specific to each filter. Not "chains" per
say.

>and of course tp is chained in a singly-linked list too which turns
>into multiple-chains.

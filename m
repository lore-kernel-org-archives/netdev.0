From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/10] net: sched: introduce multichain support
 for filters
Date: Tue, 2 May 2017 07:50:02 +0200
Message-ID: <20170502055002.GA1877@nanopsycho.orion>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
 <CAM_iQpXUs1301-OR1_bsO-0bU8sSBVo2BWRHy4qNhzdHxvJWaQ@mail.gmail.com>
 <20170428065349.GB1886@nanopsycho.orion>
 <CAM_iQpXU0nKUMg3CqE=UOZ5R=mkxSAEFANObGt6+vKEeyXXXZg@mail.gmail.com>
 <20170428223446.GB1905@nanopsycho.orion>
 <CAM_iQpX8i5-YZRkKN9DyvjCeE8W4M33wiUUTHizsyGsnsE=0KQ@mail.gmail.com>
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
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33310 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752042AbdEBFuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 01:50:06 -0400
Received: by mail-wr0-f195.google.com with SMTP id w50so15540544wrc.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 22:50:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpX8i5-YZRkKN9DyvjCeE8W4M33wiUUTHizsyGsnsE=0KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 02, 2017 at 07:26:07AM CEST, xiyou.wangcong@gmail.com wrote:
>On Fri, Apr 28, 2017 at 3:34 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Fri, Apr 28, 2017 at 07:40:24PM CEST, xiyou.wangcong@gmail.com wrote:
>>>On Thu, Apr 27, 2017 at 11:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Thu, Apr 27, 2017 at 07:46:03PM CEST, xiyou.wangcong@gmail.com wrote:
>>>>>On Thu, Apr 27, 2017 at 4:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>> Simple example:
>>>>>> $ tc qdisc add dev eth0 ingress
>>>>>> $ tc filter add dev eth0 parent ffff: protocol ip pref 33 flower dst_mac 52:54:00:3d:c7:6d action goto chain 11
>>>>>> $ tc filter add dev eth0 parent ffff: protocol ip pref 22 chain 11 flower dst_ip 192.168.40.1 action drop
>>>>>> $ tc filter show dev eth0 root
>>>>>
>>>>>Interesting.
>>>>>
>>>>>I don't look into the code yet. If I understand the concepts correctly,
>>>>>so with your patchset we can mark either filter with a chain No. to
>>>>>choose which chain it belongs to _logically_ even though
>>>>>_physically_ it is still in the old-fashion chain (prio, proto)?
>>>>
>>>> You have to see the code :)
>>>
>>>I don't understand why I have to, these are high-level concepts
>>>and should be put in your cover letter (aka. design doc). You miss
>>>a lot of information about the ordering here.
>>
>> Well, the description is one thing, but seeing the actual code should
>> put the whole view. But if you are missing something, I can add it. What
>> do you mean by "information about the ordering"?
>>
>
>By ordering, I mean:
>
>1) before your patch, filters are ordered by prio and categorized by proto
>
>2) after your patch, we can jump from one filter to a specified one, how
>does this work or not work with the prio/proto?

No, you can jump to another chain. And that chain is also ordered by
prio/proto.

Just imagine currently you have only chain 0. This patchset just extends
for other chains.

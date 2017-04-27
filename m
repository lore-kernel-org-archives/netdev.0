From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 27 Apr 2017 08:30:39 +0200
Message-ID: <20170427063039.GB1870@nanopsycho.orion>
References: <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
 <8f1a1b14-ad9b-7840-1fa6-04f2a2e4f55d@mojatatu.com>
 <20170426120851.GE1867@nanopsycho.orion>
 <10fe2c22-8e76-543e-dd24-ddce5813ab69@mojatatu.com>
 <20170426135627.GI1867@nanopsycho.orion>
 <b32fb2fb-ffb1-aee8-5f1d-1f1e3c82b347@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33753 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753094AbdD0Gaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 02:30:52 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so2326817wmh.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 23:30:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b32fb2fb-ffb1-aee8-5f1d-1f1e3c82b347@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 26, 2017 at 10:07:08PM CEST, jhs@mojatatu.com wrote:
>On 17-04-26 09:56 AM, Jiri Pirko wrote:
>> Wed, Apr 26, 2017 at 03:14:38PM CEST, jhs@mojatatu.com wrote:
>> > On 17-04-26 08:08 AM, Jiri Pirko wrote:
>
>[..]
>

[...]

>
>> > Again: You are looking at this from a manageability point of view which
>> > is useful but not the only input into a design. If i can squeeze more
>> > data without killing usability - I am all for it. It just doesnt
>> > compute that it is ok to use a flag per attribute because it looks
>> > beautiful.
>> 
>> Hmm. Now that I'm thinking about it, why don't we have NLA_FLAGS with
>> couple of helpers around it? It will be obvious what the attr is, all
>> kernel code would use the same helpers. Would be nice.
>> 
>
>I think to have flags at that level is useful but it
>is a different hierarchy level. I am not sure the
>"actions dump large messages" is a fit for that level.

Jamal, the idea is to have exactly what you want to have. Only does not
use NLA_U32 attr for that but a special attr NLA_FLAGS which would have
well defined semantics and set of helpers to work with and enforce it.

Then, this could be easily reused in other subsystem that uses netlink

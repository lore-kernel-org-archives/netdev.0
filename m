From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 16:07:08 -0400
Message-ID: <b32fb2fb-ffb1-aee8-5f1d-1f1e3c82b347@mojatatu.com>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
 <20170426061904.GB1867@nanopsycho.orion>
 <8f1a1b14-ad9b-7840-1fa6-04f2a2e4f55d@mojatatu.com>
 <20170426120851.GE1867@nanopsycho.orion>
 <10fe2c22-8e76-543e-dd24-ddce5813ab69@mojatatu.com>
 <20170426135627.GI1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33044 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754218AbdDZUHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 16:07:11 -0400
Received: by mail-it0-f65.google.com with SMTP id z67so1809936itb.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 13:07:10 -0700 (PDT)
In-Reply-To: <20170426135627.GI1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 09:56 AM, Jiri Pirko wrote:
> Wed, Apr 26, 2017 at 03:14:38PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-26 08:08 AM, Jiri Pirko wrote:

[..]

>> Jiri, what are you arguing about if you have done the math? ;->
>
> I can do 3*2*64. What I cannot do is to figure out the real performance
> impact.
>

Jiri, I do a lot of very large data dumping and setting towards the
kernel. You know that. It is why I even have these patches to begin
with.

The math should be convincing enough.
48B per rule extra for just MPLS in a filter rule. I havent started
testing the overhead of flower but i do plan to use it - with about a
million rules for offloading. I will give you the numbers then.

I think we are at a stalemate.
You are not going to convince me to use an attribute with a
u8 for a bit flag when I can fit 32 of them in one attribute (with
the same cost). And I am not able to convince you that you are
wrong to put beauty first.

>> Again: You are looking at this from a manageability point of view which
>> is useful but not the only input into a design. If i can squeeze more
>> data without killing usability - I am all for it. It just doesnt
>> compute that it is ok to use a flag per attribute because it looks
>> beautiful.
>
> Hmm. Now that I'm thinking about it, why don't we have NLA_FLAGS with
> couple of helpers around it? It will be obvious what the attr is, all
> kernel code would use the same helpers. Would be nice.
>

I think to have flags at that level is useful but it
is a different hierarchy level. I am not sure the
"actions dump large messages" is a fit for that level.

cheers,
jamal

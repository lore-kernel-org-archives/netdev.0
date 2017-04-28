From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 27 Apr 2017 21:22:53 -0400
Message-ID: <c1680135-8c9f-14d0-c65e-7a5bb7d8d661@mojatatu.com>
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
 <20170427063039.GB1870@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>,
        Benjamin LaHaise <bcrl@kvack.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33161 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938985AbdD1BW4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 21:22:56 -0400
Received: by mail-it0-f68.google.com with SMTP id z67so4191573itb.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 18:22:56 -0700 (PDT)
In-Reply-To: <20170427063039.GB1870@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-27 02:30 AM, Jiri Pirko wrote:
> Wed, Apr 26, 2017 at 10:07:08PM CEST, jhs@mojatatu.com wrote:
>> On 17-04-26 09:56 AM, Jiri Pirko wrote:
>>> Wed, Apr 26, 2017 at 03:14:38PM CEST, jhs@mojatatu.com wrote:

>> I think to have flags at that level is useful but it
>> is a different hierarchy level. I am not sure the
>> "actions dump large messages" is a fit for that level.
>
> Jamal, the idea is to have exactly what you want to have. Only does not
> use NLA_U32 attr for that but a special attr NLA_FLAGS which would have
> well defined semantics and set of helpers to work with and enforce it.
>
> Then, this could be easily reused in other subsystem that uses netlink
>

Maybe I am misunderstanding:
Recall, this is what it looks like with this patchset:
<nlh><subsytem-header>[TCA_ROOT_XXXX]

TCA_ROOT_XXX is very subsystem specific. classifiers, qdiscs and many
subsystems defined their own semantics for that TLV level. This specific
"dump max" is very very specific to actions. They were crippled by the
fact you could only send 32 at a time - this allows more to be sent.

I thought initially you meant:
<nlh>[NLA_XXX]<subsytem-header>[TCA_ROOT_XXXX]

I think at the NLA_XXX you could fit netlink wide TLVs - but if i said
"do a large dump" it is of no use to any other subsystem.

cheers,
jamal

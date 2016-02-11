From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] codel: add forgotten inline to functions in header file
Date: Thu, 11 Feb 2016 07:46:35 -0800
Message-ID: <CAA93jw5fY9faaFR8hqxXTMGkg34ONbe0Keo_RC-fyTMW6oFO4Q@mail.gmail.com>
References: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
	<1455201038.19473.12.camel@edumazet-glaptop2.roam.corp.google.com>
	<0BA3FCBA62E2DC44AF3030971E174FB32EA0E6FD@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:33600 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbcBKPqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 10:46:39 -0500
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32EA0E6FD@hasmsx107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2016 at 7:05 AM, Grumbach, Emmanuel
<emmanuel.grumbach@intel.com> wrote:
> fixing linux-wireless address ...
>
> On 02/11/2016 04:30 PM, Eric Dumazet wrote:
>> On Thu, 2016-02-11 at 16:08 +0200, Emmanuel Grumbach wrote:
>>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
>>> ---
>>> -static bool codel_should_drop(const struct sk_buff *skb,
>>> -                          struct Qdisc *sch,
>>> -                          struct codel_vars *vars,
>>> -                          struct codel_params *params,
>>> -                          struct codel_stats *stats,
>>> -                          codel_time_t now)
>>> +static inline bool codel_should_drop(const struct sk_buff *skb,
>>> +                                 struct Qdisc *sch,
>>> +                                 struct codel_vars *vars,
>>> +                                 struct codel_params *params,
>>> +                                 struct codel_stats *stats,
>>> +                                 codel_time_t now)
>>
>> The lack of inline was done on purpose.
>>
>> This include file is kind of special, being included by codel and
>> fq_codel.
>>
>> Hint : we do not want to force the compiler to inline
>> codel_should_drop() (or any other function).
>>
>>
>> See this file as if it was a .c really.
>>
>>
>
> Yeah :) codel_should_drop seemed very long indeed... I wanted to use the
> codel_get_time and associated utils (_before, _after) in iwlwifi.
> They're better than jiffies... So maybe I can just copy that code to
> iwlwifi.

I need to stress that codel as is is not the right thing for wifi,
particularly point to multipoint wifi in highly contended scenarios.
It IS a starting point. We have generally felt that the target needs
to be offset against the actual service opportunities, and the effects
of multicast (with powersave) and other "background" frames, needs to
be smoothed out.

Lacking hardware that can do that, or adaquate sims, has stalled
trying to come up with "the right thing". It looks like you are
putting in place more of the pieces to get there in some tree
somewhere?

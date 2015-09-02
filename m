From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] flow_dissector: Use 'const' where possible.
Date: Wed, 2 Sep 2015 10:05:09 -0700
Message-ID: <CALx6S37-pH5GUU34EMvLGgm5V3T7jETrKu99A4CVVxKwM_-7RQ@mail.gmail.com>
References: <20150901.211944.1246891781745159331.davem@davemloft.net>
	<CALx6S36wADimvHTc185w4Z8Ctg1D9P9SpsrHRh3vzOtBXptZtw@mail.gmail.com>
	<20150902163934.GB2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33661 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623AbbIBRFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 13:05:10 -0400
Received: by igbkq10 with SMTP id kq10so30390579igb.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 10:05:09 -0700 (PDT)
In-Reply-To: <20150902163934.GB2165@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 9:39 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Sep 02, 2015 at 06:33:34AM CEST, tom@herbertland.com wrote:
>>On Tue, Sep 1, 2015 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>> ---
>>>  include/linux/skbuff.h    |  8 ++---
>>>  include/net/flow.h        |  8 ++---
>>>  net/core/flow_dissector.c | 79 ++++++++++++++++++++++++-----------------------
>>>  3 files changed, 49 insertions(+), 46 deletions(-)
>>>
>
> <snip>
>
>
>>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>>> index 345a040..d79699c 100644
>>> --- a/net/core/flow_dissector.c
>>> +++ b/net/core/flow_dissector.c
>>> @@ -19,14 +19,14 @@
>>>  #include <net/flow_dissector.h>
>>>  #include <scsi/fc/fc_fcoe.h>
>>>
>>> -static bool skb_flow_dissector_uses_key(struct flow_dissector *flow_dissector,
>>> -                                       enum flow_dissector_key_id key_id)
>>> +static bool dissector_uses_key(const struct flow_dissector *flow_dissector,
>>> +                              enum flow_dissector_key_id key_id)
>>>  {
>>>         return flow_dissector->used_keys & (1 << key_id);
>>>  }
>>>
>>> -static void skb_flow_dissector_set_key(struct flow_dissector *flow_dissector,
>>> -                                      enum flow_dissector_key_id key_id)
>>> +static void dissector_set_key(struct flow_dissector *flow_dissector,
>>> +                             enum flow_dissector_key_id key_id)
>>>  {
>>>         flow_dissector->used_keys |= (1 << key_id);
>>>  }
>>> @@ -51,20 +51,20 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
>>
>>I suppose we should drop skb_ from skb_flow_dissector_init and
>>skb_flow_dissector_target as well.
>
> I like to have "namespaces" by function prefixes. Code is easier to read
> then...

Right, these functions now are independent of sk_buff. Conceptually
someone could use these for a non-skbuff application-- so it's good
design!

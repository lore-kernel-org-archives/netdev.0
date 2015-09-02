From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] flow_dissector: Use 'const' where possible.
Date: Wed, 2 Sep 2015 18:39:34 +0200
Message-ID: <20150902163934.GB2165@nanopsycho.orion>
References: <20150901.211944.1246891781745159331.davem@davemloft.net>
 <CALx6S36wADimvHTc185w4Z8Ctg1D9P9SpsrHRh3vzOtBXptZtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36751 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbbIBQjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 12:39:37 -0400
Received: by wibz8 with SMTP id z8so72256459wib.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 09:39:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36wADimvHTc185w4Z8Ctg1D9P9SpsrHRh3vzOtBXptZtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 02, 2015 at 06:33:34AM CEST, tom@herbertland.com wrote:
>On Tue, Sep 1, 2015 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  include/linux/skbuff.h    |  8 ++---
>>  include/net/flow.h        |  8 ++---
>>  net/core/flow_dissector.c | 79 ++++++++++++++++++++++++-----------------------
>>  3 files changed, 49 insertions(+), 46 deletions(-)
>>

<snip>


>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 345a040..d79699c 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -19,14 +19,14 @@
>>  #include <net/flow_dissector.h>
>>  #include <scsi/fc/fc_fcoe.h>
>>
>> -static bool skb_flow_dissector_uses_key(struct flow_dissector *flow_dissector,
>> -                                       enum flow_dissector_key_id key_id)
>> +static bool dissector_uses_key(const struct flow_dissector *flow_dissector,
>> +                              enum flow_dissector_key_id key_id)
>>  {
>>         return flow_dissector->used_keys & (1 << key_id);
>>  }
>>
>> -static void skb_flow_dissector_set_key(struct flow_dissector *flow_dissector,
>> -                                      enum flow_dissector_key_id key_id)
>> +static void dissector_set_key(struct flow_dissector *flow_dissector,
>> +                             enum flow_dissector_key_id key_id)
>>  {
>>         flow_dissector->used_keys |= (1 << key_id);
>>  }
>> @@ -51,20 +51,20 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
>
>I suppose we should drop skb_ from skb_flow_dissector_init and
>skb_flow_dissector_target as well.

I like to have "namespaces" by function prefixes. Code is easier to read
then...

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow_dissector: Use 'const' where possible.
Date: Tue, 01 Sep 2015 22:32:38 -0700 (PDT)
Message-ID: <20150901.223238.302696632387058866.davem@davemloft.net>
References: <20150901.211944.1246891781745159331.davem@davemloft.net>
	<CALx6S36wADimvHTc185w4Z8Ctg1D9P9SpsrHRh3vzOtBXptZtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbbIBFcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 01:32:41 -0400
In-Reply-To: <CALx6S36wADimvHTc185w4Z8Ctg1D9P9SpsrHRh3vzOtBXptZtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 1 Sep 2015 21:33:34 -0700

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
> I suppose we should drop skb_ from skb_flow_dissector_init and
> skb_flow_dissector_target as well.

I did it here because the functions were local and the lines would be
too long for even the first argument otherwise.

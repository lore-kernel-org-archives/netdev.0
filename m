From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow_dissector: Use 'const' where possible.
Date: Wed, 02 Sep 2015 11:42:23 -0700 (PDT)
Message-ID: <20150902.114223.133749270197332524.davem@davemloft.net>
References: <20150901.211944.1246891781745159331.davem@davemloft.net>
	<CALx6S36wADimvHTc185w4Z8Ctg1D9P9SpsrHRh3vzOtBXptZtw@mail.gmail.com>
	<20150902163934.GB2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142AbbIBSmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:42:24 -0400
In-Reply-To: <20150902163934.GB2165@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 2 Sep 2015 18:39:34 +0200

> Wed, Sep 02, 2015 at 06:33:34AM CEST, tom@herbertland.com wrote:
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

I completely disagree.

These are static, local functions, the can use whatever names they want
and the shorter the better.

Long function names drive me absolutely insane and make keeping the
argument lists under ~80 columns a royal pain in the ass.

So I will continue to trim function names down to something more
reasonable when they are static and local to a source file.

And I encourage you to do so as well.

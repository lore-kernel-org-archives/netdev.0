From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sk-filter: Rate-limit WARNing, print dbg info.
Date: Tue, 17 May 2011 15:23:57 -0400 (EDT)
Message-ID: <20110517.152357.85105240786269960.davem@davemloft.net>
References: <1305657014-32736-1-git-send-email-greearb@candelatech.com>
	<1305658349.1722.30.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756445Ab1EQTYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:24:06 -0400
In-Reply-To: <1305658349.1722.30.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 17 May 2011 11:52:29 -0700

> On Tue, 2011-05-17 at 11:30 -0700, greearb@candelatech.com wrote:
>> From: Ben Greear <greearb@candelatech.com>
>> A mis-configured filter can spam the logs with
>> lots of stack traces.  Rate-limit the warnings
>> and add printout of the bogus filter information.
>> -			WARN_ON(1);
>> +			if (net_ratelimit()) {
>> +				pr_err("filter: Unknown code: %hu jt: %u tf: %u"
>> +				       " k: %u\n",
>> +				       fentry->code, (unsigned int)(fentry->jt),
>> +				       (unsigned int)(fentry->jf), fentry->k);
>> +				WARN_ON(1);
>> +			}
> 
> Maybe just using WARN is better.

Yep, it looks better to me.

> I believe the casts aren't necessary.

Also correct.

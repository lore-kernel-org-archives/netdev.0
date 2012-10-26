From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Fri, 26 Oct 2012 17:10:19 -0400 (EDT)
Message-ID: <20121026.171019.702275326710216395.davem@davemloft.net>
References: <20121026132422.GA25087@hmsreliant.think-freely.org>
	<508AE08B.8070303@gmail.com>
	<20121026203504.GD25087@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934153Ab2JZVKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 17:10:23 -0400
In-Reply-To: <20121026203504.GD25087@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 26 Oct 2012 16:35:04 -0400

> On Fri, Oct 26, 2012 at 03:12:11PM -0400, Vlad Yasevich wrote:
>> Look at commit 19c7e9ee that introduced this.  I don't remember all
>> the details any more, but the problem only occurred on ia64
>> (probably due its speculative load handling).
>> 
>> -vlad
>> 
> Thanks Vlad, I'll have a look see.

Ok, so this IA64 issue is all about accesses to uninitialized memory.

I think Neil's change is thus the most desirable thing to do.  Simple
memset the object to zero.

Let the compiler optimize or not optimize things as it sees fit, to
make sure the object is completely initialized.

memset() expands to __builtin_memset(), and therefore the compiler
can and will eliminate initializations to overlapping areas if such
eliminations are possible.

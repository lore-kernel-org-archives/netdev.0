From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/7] [PATCH] net,s390: provide architecture specific
 NET_SKB_PAD
Date: Tue, 01 Feb 2011 14:17:04 -0800 (PST)
Message-ID: <20110201.141704.39181377.davem@davemloft.net>
References: <20110201081647.173934635@de.ibm.com>
	<20110201081723.562745244@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	horsth@linux.vnet.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751703Ab1BAWQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 17:16:29 -0500
In-Reply-To: <20110201081723.562745244@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Tue, 01 Feb 2011 09:16:50 +0100

> From: Horst Hartmann <horsth@linux.vnet.ibm.com>
> 
> NET_SKB_PAD has been increased from 32 to 64 and later to max(32, L1_CACHE_BYTES). 
> This led to a 25% throughput decrease for streaming workloads accompanied by a                                                               
> 37% CPU cost increase on s390.
> In order to fix this provide an architecture specific NET_SKB_PAD config symbol.
> 
> Signed-off-by: Horst Hartmann <horsth@linux.vnet.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Define it in your arch specific header file like it is designed to
be overridden.

Also, even if this Kconfig thing was the right thing to do, you would
need to put a default for it generically in init/Kconfig or
lib/Kconfig or similar.  As this is where the central documentation
for the knob would be placed.

Lastly, you failed in your commit message to describe why you wanted
to use this whacky Kconfig mechanism to override instead of using
a straight CPP define in the s390 headers.

You're modifying generic code, so you better explain what you're doing
and exactly why.

I'm not applying this series until you fix up this change, resubmit
the entire series when you have this stuff fixed up.

Thanks.


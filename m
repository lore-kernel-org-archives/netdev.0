From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 17:15:17 -0700 (PDT)
Message-ID: <20090909.171517.34998160.davem@davemloft.net>
References: <4AA819D8.1020306@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce.Yu@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752713AbZIJAPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 20:15:01 -0400
In-Reply-To: <4AA819D8.1020306@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joyce Yu <Joyce.Yu@sun.com>
Date: Wed, 09 Sep 2009 14:10:48 -0700

> drivers/net/niu.h |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)

Can I get a more verbose commit message than this?

> @@ -2700,7 +2700,7 @@ struct fcram_hash_ipv6 {
> #define RCR_PKT_TYPE_UDP               0x2
> #define RCR_PKT_TYPE_SCTP              0x3
> 
> -#define NIU_RXPULL_MAX                 ETH_HLEN
> +#define NIU_RXPULL_MAX                 64
> 

See, that's why I want a detailed commit message, because if you
described things more clearly I'd understand why you choose the value
'64' as opposed to, say, the size of a VLAN header which to me would
be a more appropriate value to use here.

You just seem to be reverting a change I made a while back, and it
just so happens to fix your problem.  But '64' is too large a value
to use here and it will impact performance.

You did check to see if there were any performance regressions
resulting from your change, right?

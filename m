From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7 net-2.6.26] [TIPC]: Remove inlining of reference
 table locking routines
Date: Tue, 15 Apr 2008 19:00:01 -0700 (PDT)
Message-ID: <20080415.190001.248179700.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-2-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752127AbYDPCAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:00:02 -0400
In-Reply-To: <1208288637-15304-2-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:51 -0400

> @@ -104,7 +135,7 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
>  
>  void tipc_ref_table_stop(void)
>  {
> -	if (!tipc_ref_table.entries)
> +	if (unlikely(tipc_ref_table.entries == NULL))
>  		return;

Please don't mix gratuitous coding style changes with functional
changes.  It makes auditing and review harder.

And in this case I prefer the more concise "!ptr".

It also could be argued that this isn't a fast path and thus
the likely/unlikely tags are not only unnecessary, but also
likely to result in code bloat for no real gain.

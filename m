From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Mon, 29 Oct 2012 15:04:44 -0400 (EDT)
Message-ID: <20121029.150444.905377521761602639.davem@davemloft.net>
References: <20121026.171019.702275326710216395.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7076@saturn3.aculab.com>
	<20121029185932.GC10177@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab2J2TEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 15:04:46 -0400
In-Reply-To: <20121029185932.GC10177@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 29 Oct 2012 14:59:32 -0400

> I don't think thats whats going on at all.  The problem, as commit
> 19c7e9eef503dc1ae926f3d26c56f88bee568d7b describes it, is that ia64 was
> speculatively loading a value from memory of type sctp_arg_t.  If the
> initialization step set the value of one of the smaller members of the union
> (say a short), then the load stage may still load a larger amount of data (given
> that the union is larger than its smallest members).  That results in part of
> the load being uninitalized, and ia64 declaring it Not A Thing, and consequently
> trapping out.

Agreed.

> The fix previously was to just initazlie the unsigned long member zero in that
> union before setting the actuall type member that was requried so as to ensure
> all the data was initalized.  That works well enough, but it presumes that
> unsigned long is the largest member of the union, which is risky.  Its better to
> memset the union to 0 for sizeof bytes to ensure future proofing.

Also agreed.

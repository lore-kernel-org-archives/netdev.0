From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/8] igb: Update queue reinit function to call dev_close
 when init of queues fails
Date: Mon, 02 Dec 2013 13:33:48 -0500 (EST)
Message-ID: <20131202.133348.1105868057685866767.davem@davemloft.net>
References: <20131129.154757.2160926223289559260.davem@davemloft.net>
	<9BBC4E0CF881AA4299206E2E1412B6264FA00871@ORSMSX102.amr.corp.intel.com>
	<1386004696.1516.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab3LBSdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 13:33:52 -0500
In-Reply-To: <1386004696.1516.15.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 2 Dec 2013 17:18:16 +0000

> David is saying that you should implement the reconfiguration in such a
> way that you can always roll back to the previous working state in case
> of a failure (which would make my concerns moot).  This is definitely a
> good goal but I'm not convinced that it's always possible.

In this case it is always possible.

The only failure possible in these code paths is for a memory
allocation failure.  Therefore, without a doubt, trying to allocate
the memory first before making any changes will provably allow perfect
rollback to a working state.  In fact, no state will be changed at all
if the allocation fails.

That's the whole point of my suggestion.  Do the one thing that
can fail, the memory allocation, before adjusting anything else.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix memory hook reference counting crashes
Date: Sat, 25 Apr 2015 14:43:54 -0400 (EDT)
Message-ID: <20150425.144354.1149917806926276049.davem@davemloft.net>
References: <1429854752-5698-1-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, anton@samba.org,
	cascardo@linux.vnet.ibm.com
To: mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbDYSn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 14:43:56 -0400
In-Reply-To: <1429854752-5698-1-git-send-email-mpe@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Ellerman <mpe@ellerman.id.au>
Date: Fri, 24 Apr 2015 15:52:32 +1000

> The recent commit to only register the EHEA memory hotplug hooks on
> adapter probe has a few problems.
> 
> Firstly the reference counting is wrong for multiple adapters, in that
> the hooks are registered multiple times. Secondly the check in the tear
> down path is backward. Finally the error path doesn't decrement the
> count.
> 
> The multiple registration of the hooks is the biggest problem, as it
> leads to oopses when the system is rebooted, and/or errors during memory
> hotplug, eg:
 ...
> Fixes: aa183323312d ("ehea: Register memory hotplug, reboot and crash hooks on adapter probe")
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

Applied, but using an atomic counter for this is really inappropriate
and is what lead to this bug in the first place.

You're not counting anything, because if you were, then you would be
decrementing this thing somewhere.

Rather, it's purely a boolean state saying "I did X".  So it should be
a boolean, and no atomicity nor other special considerations are
needed for setting it to true.

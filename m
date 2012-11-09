From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Handle very small SO_SNDTIMEOs
Date: Fri, 09 Nov 2012 16:58:00 -0500 (EST)
Message-ID: <20121109.165800.16694284057880590.davem@davemloft.net>
References: <1352389908-28587-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab2KIV6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:58:02 -0500
In-Reply-To: <1352389908-28587-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu,  8 Nov 2012 07:51:48 -0800

> From: Andi Kleen <ak@linux.intel.com>
> 
> When the SO_SNDTIMEO timeout is short enough it may round down to zero
> jiffies.   This causes unexpected behaviour because the socket
> essentially becomes always non blocking.
> 
> Round up the timeout to at least two jiffies, so that
> we guarantee waiting for at least some time. With one jiffie
> we could potentially still wait zero time because we might
> be just at the edge of the jiffie, and if it flips over
> in the middle of the check it could be still zero.
> 
> This has been observed in a real application.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Please use usecs_to_jiffies() and, if necessary, implement the policy
there.

I'm sure that things like poll() et al. have similar if not identical
issues.  Therefore it's better to have some generic spot deal with
this problem generically.

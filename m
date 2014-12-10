From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netfront: use correct linear area after
 linearizing an skb
Date: Tue, 09 Dec 2014 21:41:59 -0500 (EST)
Message-ID: <20141209.214159.1151143350544712995.davem@davemloft.net>
References: <1418150608-26180-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbaLJCmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 21:42:02 -0500
In-Reply-To: <1418150608-26180-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 9 Dec 2014 18:43:28 +0000

> Commit 97a6d1bb2b658ac85ed88205ccd1ab809899884d (xen-netfront: Fix
> handling packets on compound pages with skb_linearize) attempted to
> fix a problem where an skb that would have required too many slots
> would be dropped causing TCP connections to stall.
> 
> However, it filled in the first slot using the original buffer and not
> the new one and would use the wrong offset and grant access to the
> wrong page.
> 
> Netback would notice the malformed request and stop all traffic on the
> VIF, reporting:
> 
>     vif vif-3-0 vif3.0: txreq.offset: 85e, size: 4002, end: 6144
>     vif vif-3-0 vif3.0: fatal error; disabling device
> 
> Reported-by: Anthony Wright <anthony@overnetdata.com>
> Tested-by: Anthony Wright <anthony@overnetdata.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied and queued up for -stable, thanks.

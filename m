From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] skge: don't mark carrier down at start
Date: Wed, 23 Feb 2011 16:52:43 -0800
Message-ID: <20110223165243.8a536913.akpm@linux-foundation.org>
References: <bug-29612-10286@https.bugzilla.kernel.org/>
	<20110223162156.17ab2bc5.akpm@linux-foundation.org>
	<20110223164449.2a5206b8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, gbillios@gmail.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55381 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754205Ab1BXAxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 19:53:38 -0500
In-Reply-To: <20110223164449.2a5206b8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Feb 2011 16:44:49 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> The API for network devices has changed so that setting carrier
> off at probe is no longer required. This should fix the IPv6 addrconf
> issue.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/skge.c	2011-02-23 16:40:36.351045685 -0800
> +++ b/drivers/net/skge.c	2011-02-23 16:40:48.315136410 -0800
> @@ -3856,9 +3856,6 @@ static struct net_device *skge_devinit(s
>  	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);
>  	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
>  
> -	/* device is off until link detection */
> -	netif_carrier_off(dev);
> -
>  	return dev;
>  }

Thanks, but please don't forget to acknowledge the bug reporter's
efforts.

Also, quoting the bugzilla URL in the changelog helps when people come
along to close off open bug reports.


From: Stephen Hemminger <shemminger@linux-foundation.org>

The API for network devices has changed so that setting carrier off at
probe is no longer required.  This should fix the IPv6 addrconf issue.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=29612

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Reported-by: George Billios <gbillios@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/skge.c |    3 ---
 1 file changed, 3 deletions(-)

diff -puN drivers/net/skge.c~skge-dont-mark-carrier-down-at-start drivers/net/skge.c
--- a/drivers/net/skge.c~skge-dont-mark-carrier-down-at-start
+++ a/drivers/net/skge.c
@@ -3856,9 +3856,6 @@ static struct net_device *skge_devinit(s
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	/* device is off until link detection */
-	netif_carrier_off(dev);
-
 	return dev;
 }
 
_


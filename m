From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix a race condition in calls to slave MII
 ioctls
Date: Wed, 28 Oct 2009 22:25:01 -0700 (PDT)
Message-ID: <20091028.222501.264905294.davem@davemloft.net>
References: <20091021130301.GA4762@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751798AbZJ2FYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 01:24:38 -0400
In-Reply-To: <20091021130301.GA4762@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Wed, 21 Oct 2009 15:03:01 +0200

> Hi,
> 
> In mii monitor mode, bond_check_dev_link() calls the the ioctl
> handler of slave devices. It stores the ndo_do_ioctl function
> pointer to a static (!) ioctl variable and later uses it to call the
> handler with the IOCTL macro.
> 
> If another thread executes bond_check_dev_link() at the same time
> (even with a different bond, which none of the locks prevent), a
> race condition occurs. If the two racing slaves have different
> drivers, this may result in one driver's ioctl handler being
> called with a pointer to a net_device controlled with a different
> driver, resulting in unpredictable breakage.
> 
> Unless I am overlooking something, the "static" must be a
> copy'n'paste error (?).
> 
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Cur and paste... from where?  If you look at the 2.6.14-->2.6.14.1
commit in the history-2.6 tree (5db5272c) this static was there from
the moment the link status checking got added to the bonding driver
in Linus's tree.

Nevertheless indeed it is an awful bug, patch applied, thanks!

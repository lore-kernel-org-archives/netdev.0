From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: fix a soft lockup in vxlan module
 removal
Date: Fri, 09 Aug 2013 11:42:45 -0700 (PDT)
Message-ID: <20130809.114245.1171395854188554598.davem@davemloft.net>
References: <1375865002-8732-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967943Ab3HISmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:42:46 -0400
In-Reply-To: <1375865002-8732-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  7 Aug 2013 16:43:22 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> This is a regression introduced by:
> 
> 	commit fe5c3561e6f0ac7c9546209f01351113c1b77ec8
> 	Author: stephen hemminger <stephen@networkplumber.org>
> 	Date:   Sat Jul 13 10:18:18 2013 -0700
> 
> 	    vxlan: add necessary locking on device removal
> 
> The problem is that vxlan_dellink(), which is called with RTNL lock
> held, tries to flush the workqueue synchronously, but apparently
> igmp_join and igmp_leave work need to hold RTNL lock too, therefore we
> have a soft lockup! 
> 
> As suggested by Stephen, probably the flush_workqueue can just be
> removed and let the normal refcounting work. The workqueue has a
> reference to device and socket, therefore the cleanups should work
> correctly.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Tested-by: Cong Wang <amwang@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.

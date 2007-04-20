From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] PPPOE: Fix device tear-down notification.
Date: Fri, 20 Apr 2007 16:59:55 -0700 (PDT)
Message-ID: <20070420.165955.52750075.davem@davemloft.net>
References: <1173794975536-git-send-email-mostrows@earthlink.net>
	<11737949751582-git-send-email-mostrows@earthlink.net>
	<11737949753280-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@watson.ibm.com, netdev@vger.kernel.org
To: mostrows@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752795AbXDTX7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:59:51 -0400
In-Reply-To: <11737949753280-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Ostrowski <mostrows@earthlink.net>
Date: Tue, 13 Mar 2007 09:09:35 -0500

> pppoe_flush_dev() kicks all sockets bound to a device that is going down.
> In doing so, locks must be taken in the right order consistently (sock lock,
> followed by the pppoe_hash_lock).  However, the scan process is based on
> us holding the sock lock.  So, when something is found in the scan we must
> release the lock we're holding and grab the sock lock.
> 
> This patch fixes race conditions between this code and pppoe_release(),
> both of which perform similar functions but would naturally prefer to grab
> locks in opposing orders.  Both code paths are now going after these locks
> in a consistent manner.
> 
> pppoe_hash_lock protects the contents of the "pppox_sock" objects that reside
> inside the hash.  Thus, NULL'ing out the pppoe_dev field should be done
> under the protection of this lock.
> 
> Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>

Aha, this one applies cleanly :-)

But I had to edit out some trailing whitespace this patch
added, please be mindful of this in the future, thanks!

Adds trailing whitespace.
diff:48:			
Adds trailing whitespace.
diff:52:			 * hold the sock lock while doing any unbinding, 
Adds trailing whitespace.
diff:53:			 * we need to release the lock we're holding.  
Adds trailing whitespace.
diff:81:		
Adds trailing whitespace.
diff:121:		__delete_item(po->pppoe_pa.sid, 
warning: 5 lines add trailing whitespaces.

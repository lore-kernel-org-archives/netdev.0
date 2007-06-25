From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 - rev2] qdisc_restart - readability changes plus
 one bug fix.
Date: Sun, 24 Jun 2007 19:56:43 -0700 (PDT)
Message-ID: <20070624.195643.132459975.davem@davemloft.net>
References: <1181724047.10679.30.camel@localhost.localdomain>
	<1182142284.6082.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
To: kumarkr@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752347AbXFYC4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 22:56:25 -0400
In-Reply-To: <1182142284.6082.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Date: Mon, 18 Jun 2007 10:21:24 +0530

> New changes :
> 
> - Incorporated Peter Waskiewicz's comments.
> - Re-added back one warning message (on driver returning wrong value).
> 
> Previous changes :
> 
> - Converted to use switch/case code which looks neater.
> 
> - "if (ret == NETDEV_TX_LOCKED && lockless)" is buggy, and the lockless
>   check should be removed, since driver will return NETDEV_TX_LOCKED only
>   if lockless is true and driver has to do the locking. In the original
>   code as well as the latest code, this code can result in a bug where
>   if LLTX is not set for a driver (lockless == 0) but the driver is written
>   wrongly to do a trylock (despite LLTX being set), the driver returns
>   LOCKED. But since lockless is zero, the packet is requeue'd instead of
>   calling collision code which will issue warning and free up the skb.
>   Instead this skb will be retried with this driver next time, and the same
>   result will ensue. Removing this check will catch these driver bugs instead
>   of hiding the problem. I am keeping this change to readability section
>   since :
>   	a. it is confusing to check two things as it is; and
>   	b. it is difficult to keep this check in the changed 'switch' code.
> 
> - Changed some names, like try_get_tx_pkt to dev_dequeue_skb (as that is
>   the work being done and easier to understand) and do_dev_requeue to
>   dev_requeue_skb, merged handle_dev_cpu_collision and tx_islocked to
>   dev_handle_collision (handle_dev_cpu_collision is a small routine with only
>   one caller, so there is no need to have two separate routines which also
>   results in getting rid of two macros, etc.
> 
> - Removed an XXX comment as it should never fail (I suspect this was related
>   to batch skb WIP, Jamal ?). Converted some functions to original coding
>   style of having the return values and the function name on same line, eg
>   prio2list.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Looks good, applied and pushed to net-2.6.23


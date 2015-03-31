From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Return vport module ref before
 destruction
Date: Tue, 31 Mar 2015 16:00:31 -0400 (EDT)
Message-ID: <20150331.160031.2170838715047996686.davem@davemloft.net>
References: <9cf67a5f127d80bb7db0bd1af1e33505f93e1a01.1427715582.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754372AbbCaUAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 16:00:36 -0400
In-Reply-To: <9cf67a5f127d80bb7db0bd1af1e33505f93e1a01.1427715582.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 30 Mar 2015 13:57:41 +0200

> Return module reference before invoking the respective vport
> ->destroy() function. This is needed as ovs_vport_del() is not
> invoked inside an RCU read side critical section so the kfree
> can occur immediately before returning to ovs_vport_del().
> 
> Returning the module reference before ->destroy() is safe because
> the module unregistration is blocked on ovs_lock which we hold
> while destroying the datapath.
> 
> Fixes: 62b9c8d0372d ("ovs: Turn vports with dependencies into separate modules")
> Reported-by: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> @Dave: Please also queue for 3.19.x stable series

Applied and queued up for -stable, thanks Thomas.

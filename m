From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix deadlock during socket release
Date: Sun, 29 Dec 2013 22:24:35 -0500 (EST)
Message-ID: <20131229.222435.1179109367469102281.davem@davemloft.net>
References: <1388110708-11890-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	lars.everbrand@ericsson.com, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab3L3D0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 22:26:51 -0500
In-Reply-To: <1388110708-11890-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 27 Dec 2013 10:18:28 +0800

> A deadlock might occur if name table is withdrawn in socket release
> routine, and while packets are still being received from bearer.
> 
>        CPU0                       CPU1
> T0:   recv_msg()               release()
> T1:   tipc_recv_msg()          tipc_withdraw()
> T2:   [grab node lock]         [grab port lock]
> T3:   tipc_link_wakeup_ports() tipc_nametbl_withdraw()
> T4:   [grab port lock]*        named_cluster_distribute()
> T5:   wakeupdispatch()         tipc_link_send()
> T6:                            [grab node lock]*
> 
> The opposite order of holding port lock and node lock on above two
> different paths may result in a deadlock. If socket lock instead of
> port lock is used to protect port instance in tipc_withdraw(), the
> reverse order of holding port lock and node lock will be eliminated,
> as a result, the deadlock is killed as well.
> 
> Reported-by: Lars Everbrand <lars.everbrand@ericsson.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.

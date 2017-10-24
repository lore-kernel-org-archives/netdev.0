From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: Fix actions list corruption when
 adding offloaded tc flows
Date: Tue, 24 Oct 2017 19:01:19 +0900 (KST)
Message-ID: <20171024.190119.318681859354315835.davem@davemloft.net>
References: <1508824682-5088-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com, roid@mellanox.com,
        paulb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdJXKBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 06:01:23 -0400
In-Reply-To: <1508824682-5088-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 24 Oct 2017 08:58:02 +0300

> Prior to commit b3f55bdda8df, the networking core doesn't wire an in-place
> actions list the when the low level driver is called to offload the flow,
> but all low level drivers do that (call tcf_exts_to_list()) in their
> offloading "add" logic.
> 
> Now, the in-place list is set in the core which goes over the list in a loop,
> but also by the hw driver when their offloading code is invoked indirectly:
> 
> 	cls_xxx add flow -> tc_setup_cb_call -> tc_exts_setup_cb_egdev_call -> hw driver
> 
> which messes up the core list instance upon driver return. Fix that by avoiding
> in-place list on the net core code that deals with adding flows.
> 
> Fixes: b3f55bdda8df ('net: sched: introduce per-egress action device callbacks')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.

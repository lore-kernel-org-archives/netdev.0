From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in
 ovs_ct_find_existing() if NATted.
Date: Sun, 05 Feb 2017 17:28:24 -0500 (EST)
Message-ID: <20170205.172824.848224453582586032.davem@davemloft.net>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdBEW2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 17:28:25 -0500
In-Reply-To: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Thu,  2 Feb 2017 17:10:00 -0800

> This does not match either of the conntrack tuples above.  Normally
> this does not matter, as the conntrack lookup was already done using
> the tuple (B,A), but if the current packet does not match any flow in
> the OVS datapath, the packet is sent to userspace via an upcall,
> during which the packet's skb is freed, and the conntrack entry
> pointer in the skb is lost.

This is the real bug.

If the metadata for a packet is important, as it obviously is here,
then upcalls should preserve that metadata across the upcall.  This
is exactly how NF_QUEUE handles this problem and so should OVS.

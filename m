From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 8021q: skip packets if the vlan is down
Date: Wed, 04 Oct 2017 18:23:29 -0700 (PDT)
Message-ID: <20171004.182329.616816521170306524.davem@davemloft.net>
References: <1507061609-11972-1-git-send-email-Vishakha.Narvekar@dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allen.hubbe@dell.com, andrew.boyer@dell.com
To: Vishakha.Narvekar@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751177AbdJEBXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 21:23:30 -0400
In-Reply-To: <1507061609-11972-1-git-send-email-Vishakha.Narvekar@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vishakha Narvekar <Vishakha.Narvekar@dell.com>
Date: Tue,  3 Oct 2017 16:13:29 -0400

> If the vlan is down, free the packet instead of proceeding with other
> processing, or counting it as received.  If vlan interfaces are used
> as slaves for bonding, with arp monitoring for connectivity, if the rx
> counter is seen to be incrementing, then the bond device will not
> observe that the interface is down.
> 
> CC: David S. Miller <davem@davemloft.net>
> Signed-off-by: Vishakha Narvekar <Vishakha.Narvekar@dell.com>

I've applied this for now.

This is likely the best we can do in the software case.

In the hardware offload case, we really should (via the notifier for
the vlan device going down), tell the hardware to stop receiving vlan
packets.

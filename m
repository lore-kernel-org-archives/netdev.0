From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: Fix performance issues with vlan tagged
 packets
Date: Mon, 15 May 2017 14:17:49 -0400 (EDT)
Message-ID: <20170515.141749.698049536255759644.davem@davemloft.net>
References: <1494515392-30826-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
        vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932653AbdEOSRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 14:17:51 -0400
In-Reply-To: <1494515392-30826-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Thu, 11 May 2017 11:09:52 -0400

> Macvlan always turns on offload features that have sofware
> fallback (NETIF_GSO_SOFTWARE).  This allows much higher guest-guest
> communications over macvtap.
> 
> However, macvtap does not turn on these features for vlan tagged traffic.
> As a result, depending on the HW that mactap is configured on, the
> performance of guest-guest communication over a vlan is very
> inconsistent.  If the HW supports TSO/UFO over vlans, then the
> performance will be fine.  If not, the the performance will suffer
> greatly since the VM may continue using TSO/UFO, and will force the host
> segment the traffic and possibly overlow the macvtap queue.
> 
> This patch adds the always on offloads to vlan_features.  This
> makes sure that any vlan tagged traffic between 2 guest will not
> be segmented needlessly.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Indeed, this makes us more consistent with how we handle non-vlan
features in macvtap.

Applied, thanks.

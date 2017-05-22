From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bonding: fix accounting of active ports in 3ad
Date: Mon, 22 May 2017 12:06:25 -0400 (EDT)
Message-ID: <20170522.120625.881809083833962546.davem@davemloft.net>
References: <20170517151144.57865-1-jarod@redhat.com>
        <20170519234345.44721-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53768 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdEVQG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 12:06:27 -0400
In-Reply-To: <20170519234345.44721-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Fri, 19 May 2017 19:43:45 -0400

> As of 7bb11dc9f59d and 0622cab0341c, bond slaves in a 3ad bond are not
> removed from the aggregator when they are down, and the active slave count
> is NOT equal to number of ports in the aggregator, but rather the number
> of ports in the aggregator that are still enabled. The sysfs spew for
> bonding_show_ad_num_ports() has a comment that says "Show number of active
> 802.3ad ports.", but it's currently showing total number of ports, both
> active and inactive. Remedy it by using the same logic introduced in
> 0622cab0341c in __bond_3ad_get_active_agg_info(), so sysfs, procfs and
> netlink all report the number of active ports. Note that this means that
> IFLA_BOND_AD_INFO_NUM_PORTS really means NUM_ACTIVE_PORTS instead of
> NUM_PORTS, and thus perhaps should be renamed for clarity.
> 
> Lightly tested on a dual i40e lacp bond, simulating link downs with an ip
> link set dev <slave2> down, was able to produce the state where I could
> see both in the same aggregator, but a number of ports count of 1.
 ...
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> v2: fix incorrect git sha reference, add more testing data

Applied and queued up for -stable, thanks Jarod!

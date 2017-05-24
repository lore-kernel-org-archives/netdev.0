From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net 0/3] Fix checksum issues with Q-in-Q vlans
Date: Wed, 24 May 2017 16:25:36 -0400 (EDT)
Message-ID: <20170524.162536.1889441467704319346.davem@davemloft.net>
References: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
        makita.toshiaki@lab.ntt.co.jp, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032687AbdEXUZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 16:25:38 -0400
In-Reply-To: <1495561123-1819-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 23 May 2017 13:38:40 -0400

> TCP checksum appear broken on a lot of devices that
> advertise NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM.  This problem
> becomes very visible/reproducable since the series
> commit afb0bc972b526 ("Merge branch 'stacked_vlan_tso'").
> 
> In particular, the issue appeared consistently on bnx2 and be2net
> drivers (not all drivers were tested).
> 
> This short series corrects this by disabling checksum offload
> support on packets sent through Q-in-Q vlans if the underlying HW only
> enables IP specific checksum features.  We currently 'assume' that
> any drivers setting NETIF_F_HW_CSUM can correclty pass checksum offsets
> to HW.  It is up to individual drivers to enable it properly through
> ndo_features_check if they have some support for Q-in-Q vlans.
> 
> Additionally, be2net driver was fixed to make the proper call.
> 
> While looking at the drivers, it was also found that virtio-net ended
> up disabling accelerations, which is unnecessary.  
> 
> V3: Fixed checkpatch errors.
> 
> V2: Instead of disabling checksuming for all devices, only devices using
>     NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM are now affected by this change.
>     For drivers using NETIF_F_HW_CSUM, we will continue to use checksum
>     offloading.  If any drivers are found to be broken, they would need
>     be fixed individually.

Series applied and queued up for -stable, thanks.

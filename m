From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/5] bonding: locking simplifications and cleanup
Date: Tue, 3 Sep 2013 09:48:04 +0800
Message-ID: <52253FD4.1060908@huawei.com>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <andy@greyhouse.net>, <fubar@us.ibm.com>,
	<davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:18609 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab3ICBsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 21:48:13 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/9/2 19:51, Nikolay Aleksandrov wrote:
> Hello,
> This small patchset aims to remove some use cases of bond->lock for mutual
> exclusion which will help in the RCUfication of the function users. It also
> does some small style cleanups and fixes.
> 
> Patch 01 - Drops the use of bond->lock as mutual exclusion for peer
> notification and relies on RTNL being held when send_peer_notif is modified
> Patch 02 - trivial outdated comment removal
> Patch 03 - Drops the use of bond->lock as mutual exclusion for lacp rate
> update and relies on RTNL, also fixes possible races with mode change
> Patch 04 - Drops read_lock in bond_fix_features because RTNL is held
> Patch 05 - Drops read_lock in bond_compute_features because RTNL is held
> whenever it's called
> 
> Best regards,
>  Nikolay Aleksandrov
> 
> Nikolay Aleksandrov (5):
>   bonding: simplify and fix peer notification
>   bonding: trivial: remove outdated comment and braces
>   bonding: simplify bond_3ad_update_lacp_rate and use RTNL for sync
>   bonding: drop read_lock in bond_fix_features
>   bonding: drop read_lock in bond_compute_features
> 
>  drivers/net/bonding/bond_3ad.c   |  8 +------
>  drivers/net/bonding/bond_main.c  | 48 ++++++++++++----------------------------
>  drivers/net/bonding/bond_sysfs.c |  7 +++++-
>  3 files changed, 21 insertions(+), 42 deletions(-)
> 

Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>

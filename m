From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 10443] New: VLAN: link level multicasts addresses
 disappears...
Date: Sun, 13 Apr 2008 07:44:15 +0200
Message-ID: <48019DAF.4010302@trash.net>
References: <bug-10443-10286@http.bugzilla.kernel.org/>	<20080411214134.dd7a9ffc.akpm@linux-foundation.org> <20080412.001045.177916063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010006070909060005070509"
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, dmitry@butskoy.name,
	greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33706 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYDMFoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 01:44:25 -0400
In-Reply-To: <20080412.001045.177916063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010006070909060005070509
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 11 Apr 2008 21:41:34 -0700
> 
>> There's a test case in the bugzilla report.
> 
> Could be fixed by:
> 
> commit 0ed21b321a13421e2dfeaa70a6c324e05e3e91e6
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Mar 26 00:15:17 2008 -0700
> 
>     [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device

Either that patch or this one I guess:

[NET]: Messed multicast lists after dev_mc_sync/unsync

I'll go through our recent multicast fixes and check which
ones make sense for -stable.


--------------010006070909060005070509
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 12aa343add3eced38a44bdb612b35fdf634d918c
Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
Date:   Tue Feb 19 14:17:04 2008 -0800

    [NET]: Messed multicast lists after dev_mc_sync/unsync
    
    Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 ("[NET]: dev_mcast:
    add multicast list synchronization helpers") from you introduced a new
    field "da_synced" to struct dev_addr_list that is not properly
    initialized to 0. So when any of the current users (8021q, macvlan,
    mac80211) calls dev_mc_sync/unsync they mess the address list for both
    devices.
    
    The attached patch fixed it for me and avoid future problems.
    
    Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 6cfc123..9516105 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2900,7 +2900,7 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 		}
 	}
 
-	da = kmalloc(sizeof(*da), GFP_ATOMIC);
+	da = kzalloc(sizeof(*da), GFP_ATOMIC);
 	if (da == NULL)
 		return -ENOMEM;
 	memcpy(da->da_addr, addr, alen);

--------------010006070909060005070509--

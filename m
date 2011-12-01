From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] neigh: Add device constructor/destructor
 capability.
Date: Thu, 01 Dec 2011 14:16:52 -0500 (EST)
Message-ID: <20111201.141652.836407244493251809.davem@davemloft.net>
References: <20111130.224151.1479303742039627135.davem@davemloft.net>
	<1322766515.2797.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756171Ab1LATQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 14:16:57 -0500
In-Reply-To: <1322766515.2797.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Dec 2011 19:08:35 +0000

> On Wed, 2011-11-30 at 22:41 -0500, David Miller wrote:
>> If the neigh entry has device private state, it will need
>> constructor/destructor ops.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  include/linux/netdevice.h |    2 ++
>>  net/core/neighbour.c      |   15 ++++++++++++++-
>>  2 files changed, 16 insertions(+), 1 deletions(-)
>> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 5462c2c..1c4ddb3 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -974,6 +974,8 @@ struct net_device_ops {
>>  						    netdev_features_t features);
>>  	int			(*ndo_set_features)(struct net_device *dev,
>>  						    netdev_features_t features);
>> +	int			(*ndo_neigh_construct)(struct neighbour *n);
>> +	int			(*ndo_neigh_destroy)(struct neighbour *n);
> 
> ndo_neigh_destroy should return void, since the return value is not
> used:

Agreed:

--
net: Make ndo_neigh_destroy return void.

The return value isn't used.

Suggested by Ben Hucthings.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1c4ddb3..21440e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -975,7 +975,7 @@ struct net_device_ops {
 	int			(*ndo_set_features)(struct net_device *dev,
 						    netdev_features_t features);
 	int			(*ndo_neigh_construct)(struct neighbour *n);
-	int			(*ndo_neigh_destroy)(struct neighbour *n);
+	void			(*ndo_neigh_destroy)(struct neighbour *n);
 };
 
 /*
-- 
1.7.7.3

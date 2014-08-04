From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Mon, 04 Aug 2014 15:15:39 -0700 (PDT)
Message-ID: <20140804.151539.185781551061535031.davem@davemloft.net>
References: <1406634039-15030-3-git-send-email-_govind@gmx.com>
	<20140730.175306.483788306179792581.davem@davemloft.net>
	<1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaHDWPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 18:15:40 -0400
In-Reply-To: <1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 02 Aug 2014 14:56:22 +0100

> How about adding a generic operation for independent tunables:
> 
> struct ethtool_get_tunable {
> 	u32	cmd;
> 	u32	id;
> 	u64	value, min, max;
> };
> 
> struct ethtool_set_tunable {
> 	u32	cmd;
> 	u32	id;
> 	u64	value;
> };
> 
> 	int (*get_tunable)(struct net_device *, struct ethtool_get_tunable *);
> 	int (*set_tunable)(struct net_device *, const struct ethtool_set_tunable *);
> 
> The id to name mapping could be provided either through a stringset or
> macros in <uapi/linux/ethtool.h>.  And perhaps we could split the id
> space to allow for driver-specific tunables (while strongly discouraging
> those for in-tree drivers).

That would certainly work, and another approach would be that we could
also create a tunable namespace of sorts.

struct ethtool_tunable {
	u32	cmd;
	u32	len;
	u32	data[];
};

#define ETHTOOL_GTUNABLE	x
#define ETHTOOL_STUNABLE	y

...

#define ETHTOOL_TUNABLE_COPYBREAK	0x00000001	/* u32 */

etc.

I understand the reason to gravitate towards stringset, in that it would
minimize the amount of code needed in the ethtool utility itself.

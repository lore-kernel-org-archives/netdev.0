From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Wed, 11 Mar 2009 09:17:54 -0700 (PDT)
Message-ID: <20090311.091754.99441674.davem@davemloft.net>
References: <20090303170435.GE1480@hmsreliant.think-freely.org>
	<20090305192706.GB12835@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751213AbZCKQSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 12:18:09 -0400
In-Reply-To: <20090305192706.GB12835@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 5 Mar 2009 14:27:06 -0500

> +struct net_dm_drop_point {
> +	uint8_t pc[8];
> +	uint32_t count;
> +};

Please use "__u8", "__u32", etc. and you'll get those as a result
of your linux/netlink.h include at the top of this file.

> +#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)

Please don't embed return statements in macors, this makes the
code nearly impossible to audit.

I don't even see this macro being used in the code :-)

Otherwise this looks fine.

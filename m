From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bonding: use pre-defined macro in bond_mode_name
 instead of magic number 0
Date: Wed, 24 Jul 2013 00:10:19 -0700
Message-ID: <1374649819.18818.5.camel@joe-AO722>
References: <51EF79E6.9060309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Wang Sheng-Hui <shhuiw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59449 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751721Ab3GXHKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 03:10:20 -0400
In-Reply-To: <51EF79E6.9060309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 14:53 +0800, Wang Sheng-Hui wrote:
> We have BOND_MODE_ROUNDROBIN pre-defined as 0, and it's the lowest mode number.
> Use it to check the arg lower bound instead of magic number 0 in bond_mode_name.
[]
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
[]
> @@ -273,7 +273,7 @@ const char *bond_mode_name(int mode)
>   		[BOND_MODE_ALB] = "adaptive load balancing",
>   	};
> 
> -	if (mode < 0 || mode > BOND_MODE_ALB)
> +	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_ALB)
>   		return "unknown";
> 
>   	return names[mode];

Probably be simpler, less confusing, and more normal style
to use a switch case.

	switch (mode) {
	case BOND_MODE_ROUNDROBIN:
		return "load balancing (round-robin)";
	case BOND_MODE_ACTIVEBACKUP:
		return "fault-tolerance (active-backup)";
	case BOND_MODE_XOR:
		return "load balancing (xor)";
	case BOND_MODE_BROADCAST;
		return "fault-tolerance (broadcast)";
	case BOND_MODE_8023AD:
		return "IEEE 802.3ad Dynamic link aggregation";
	case BOND_MODE_TLB:
		return "transmit load balancing";
	case BOND_MODE_ALB:
		return "adaptive load balancing";
	default:
		return "unknown";
	}

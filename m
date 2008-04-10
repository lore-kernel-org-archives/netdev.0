From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] IPV4: route use jhash3
Date: Thu, 10 Apr 2008 01:54:48 -0700 (PDT)
Message-ID: <20080410.015448.00224349.davem@davemloft.net>
References: <20080401004708.009204033@vyatta.com>
	<20080401004724.752793269@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41055
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753675AbYDJIys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:54:48 -0400
In-Reply-To: <20080401004724.752793269@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 31 Mar 2008 17:47:13 -0700

> Since route hash is a triple, use jhash_3words rather doing the mixing
> directly. This should be as fast and give better distribution.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6.26, but:

> -static unsigned int rt_hash_code(u32 daddr, u32 saddr)
> +static inline unsigned int rt_hash(__be32 daddr, __be32 saddr, int idx)

Are you sure you want to inline that?  jhash expands
to a lot of instructions

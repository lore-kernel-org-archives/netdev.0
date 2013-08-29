From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] qlge: Enhance nested VLAN (Q-in-Q)
 handling.
Date: Thu, 29 Aug 2013 01:31:48 -0400 (EDT)
Message-ID: <20130829.013148.305467895644272769.davem@davemloft.net>
References: <1377751868-1367-1-git-send-email-jitendra.kalsaria@qlogic.com>
	<1377751868-1367-2-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777Ab3H2Fbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 01:31:50 -0400
In-Reply-To: <1377751868-1367-2-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Thu, 29 Aug 2013 00:51:07 -0400

> +	u16 *tags;
> +
> +	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) {
> +		tags = (u16 *)page;
> +		/* Look for stacked vlan tags in ethertype field */
> +		if (tags[6] == htons(ETH_P_8021Q) &&
> +		    tags[8] == htons(ETH_P_8021Q))

htons() returns a __be16,  there is not way that this code doesn't
generate sparse endianness errors.

Also, your change is sacrificing single layered VLAN performance
for the sake of Q-in-Q as far as I can tell.  I don't think that's
a very wise tradeoff if so.

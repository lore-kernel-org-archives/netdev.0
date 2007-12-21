From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] OOPS with NETLINK_FIB_LOOKUP netlink socket
Date: Fri, 21 Dec 2007 01:33:21 -0800 (PST)
Message-ID: <20071221.013321.164620125.davem@davemloft.net>
References: <20071221090043.GA25484@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, netdev@vger.kernel.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbXLUJdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:33:22 -0500
In-Reply-To: <20071221090043.GA25484@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 21 Dec 2007 12:00:43 +0300

> nl_fib_input re-reuses incoming skb to send the reply. This means that this
> packet will be freed twice, namely in:
> - netlink_unicast_kernel
> - on receive path
> Use clone to send as a cure, the caller is responsible for kfree_skb on error.
> 
> Thanks to Alexey Dobryan, who originally found the problem.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

What introduced this bug?  This code didn't have this
problem previously.

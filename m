From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: santize headers for iproute2
Date: Tue, 25 Dec 2007 15:02:38 -0800 (PST)
Message-ID: <20071225.150238.193724414.davem@davemloft.net>
References: <20071221094336.63600b8c@deepthought>
	<20071224.220527.254578945.davem@davemloft.net>
	<20071225124323.70e0c772@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751183AbXLYXCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 18:02:40 -0500
In-Reply-To: <20071225124323.70e0c772@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 25 Dec 2007 12:43:23 -0800

> The problem is that iproute ss.c needs linux/tcp.h to get the
> tcp_info structure definition but linux/tcp.h has incompatible
> definitions with netinet/tcp.h.  I propose that the enum be moved
> from net/tcp_states.h to linux/tcp.h.

This would be fragile, at best.

We need to solve this in a way such that both linux/tcp.h and
netinet/tcp.h can both be included at the same time by userland.

If we export linux/tcp.h to userspace, we have to make it play nice
with the existing header file namespace.

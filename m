From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] route: do not cache fib route info on local routes
 with oif
Date: Wed, 13 Apr 2016 23:34:00 -0400 (EDT)
Message-ID: <20160413.233400.893479949245860952.davem@davemloft.net>
References: <57080F7E.809@windriver.com>
	<alpine.LFD.2.11.1604082328460.2124@ja.home.ssi.bg>
	<570820DA.2070007@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: chris.friesen@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbcDNDeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 23:34:02 -0400
In-Reply-To: <570820DA.2070007@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Friesen <chris.friesen@windriver.com>
Date: Fri, 8 Apr 2016 15:21:30 -0600

> For local routes that require a particular output interface we do not want
> to cache the result.  Caching the result causes incorrect behaviour when
> there are multiple source addresses on the interface.  The end result
> being that if the intended recipient is waiting on that interface for the
> packet he won't receive it because it will be delivered on the loopback
> interface and the IP_PKTINFO ipi_ifindex will be set to the loopback
> interface as well.
> 
> This can be tested by running a program such as "dhcp_release" which
> attempts to inject a packet on a particular interface so that it is
> received by another program on the same board.  The receiving process
> should see an IP_PKTINFO ipi_ifndex value of the source interface
> (e.g., eth1) instead of the loopback interface (e.g., lo).  The packet
> will still appear on the loopback interface in tcpdump but the important
> aspect is that the CMSG info is correct.
> 
> Sample dhcp_release command line:
> 
>    dhcp_release eth1 192.168.204.222 02:11:33:22:44:66
> 
> Signed-off-by: Allain Legacy <allain.legacy@windriver.com>
> Signed off-by: Chris Friesen <chris.friesen@windriver.com>

Applied and queued up for -stable, thanks.

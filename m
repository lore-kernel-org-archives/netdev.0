From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: perform inetpeer binding at dst
 creation, with readonly option
Date: Thu, 08 Mar 2012 13:40:57 -0800 (PST)
Message-ID: <20120308.134057.343430189436877920.davem@davemloft.net>
References: <4F56320B.60400@network-box.com>
	<20120306.160528.1272258218296495399.davem@davemloft.net>
	<4F58D9F5.1080902@network-box.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nick.jones@network-box.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757510Ab2CHVlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 16:41:03 -0500
In-Reply-To: <4F58D9F5.1080902@network-box.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Jones <nick.jones@network-box.com>
Date: Fri, 09 Mar 2012 00:10:29 +0800

> However, seeing a kmalloc done for such a transient, sparse
> structure didn't sit so well in the stomach.  If we can be sure that
> the metrics of a dst for an icmp6 packet won't be written to, we
> could use the static const ip6_template_metrics array defined in
> route.c:~205, it has RTAX_HOPLIMIT fixed at 255, and using it avoids
> a kmalloc.
> 
> I'll produce another patch for this strategy if you think this is a
> better idea.

This could work, but you'll need to add an assertion or similar to make
sure this requirement always holds.

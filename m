From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Wed, 29 Oct 2014 15:12:07 -0400 (EDT)
Message-ID: <20141029.151207.33801041784232926.davem@davemloft.net>
References: <1414487474-18201-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, lorenzo@google.com,
	hannes@stressinduktion.org
To: ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756315AbaJ2TMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:12:10 -0400
In-Reply-To: <1414487474-18201-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Kline <ek@google.com>
Date: Tue, 28 Oct 2014 18:11:14 +0900

> Add a sysctl that causes an interface's optimistic addresses
> to be considered equivalent to other non-deprecated addresses
> for source address selection purposes.  Preferred addresses
> will still take precedence over optimistic addresses, subject
> to other ranking in the source address selection algorithm.
> 
> This is useful where different interfaces are connected to
> different networks from different ISPs (e.g., a cell network
> and a home wifi network).
> 
> The current behaviour complies with RFC 3484/6724, and it
> makes sense if the host has only one interface, or has
> multiple interfaces on the same network (same or cooperating
> administrative domain(s), but not in the multiple distinct
> networks case.
> 
> For example, if a mobile device has an IPv6 address on an LTE
> network and then connects to IPv6-enabled wifi, while the wifi
> IPv6 address is undergoing DAD, IPv6 connections will try use
> the wifi default route with the LTE IPv6 address, and will get
> stuck until they time out.
> 
> Also, because optimistic nodes can receive frames, issue
> an RTM_NEWADDR as soon as DAD starts (with the IFA_F_OPTIMSTIC
> flag appropriately set).  A second RTM_NEWADDR is sent if DAD
> completes (the address flags have changed), otherwise an
> RTM_DELADDR is sent.
> 
> Also: add an entry in ip-sysctl.txt for optimistic_dad.
> 
> Signed-off-by: Erik Kline <ek@google.com>

Applied, if the idev != NULL check proves to be unnecessary we can
kill it in a follow-on patch.

Thanks.

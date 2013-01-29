From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] l2tp: fix ancilliary data handling in ip6 recv
Date: Tue, 29 Jan 2013 14:12:39 -0500 (EST)
Message-ID: <20130129.141239.2228875361542418234.davem@davemloft.net>
References: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab3A2TMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:12:48 -0500
In-Reply-To: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Mon, 28 Jan 2013 10:48:52 +0000

> l2tp_ip6 was using the IPv4 handler functions for ancilliary data, which meant
> that socket options such as e.g. IPV6_RECVPKTINFO are not correctly passed to
> userspace.
> 
> This patchset:
> 
> 	*  exports the IPv6 recv handler function datagram_recv_ctl so that
> 	   modules may access it
> 	*  updates l2tp_ip6 to use datagram_recv_ctl rather than ip_cmsg_recv

What a mess.

Well, no surprise that usage of these routines is often wrong given
the non-descript names the functions have.

Please rewrite this patch set, starting with a rename of both
datagram_recv_ctl() and datagram_send_ctl() such that you can
tell, by name, that they are ipv6 specific functions.

Please make sure to grep the entire tree and fix up all references,
they are references to the names in comments too.

They currently look like generic routines that might be found in
net/core/datagram.c and might be usable for all protocols, but that's
definitely not the case.

They are ipv6 specific, and if they are exported globally they must
have something expressing their ipv6'ness in their names.

Thanks.

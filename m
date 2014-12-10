From: David Miller <davem@davemloft.net>
Subject: Re: PATCH] Revert "bridge: include in6.h in if_bridge.h for struct
 in6_addr"
Date: Tue, 09 Dec 2014 23:49:54 -0500 (EST)
Message-ID: <20141209.234954.1634249639621060084.davem@davemloft.net>
References: <20141209203007.188651df@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.0xf0@gmail.com, f.fainelli@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265AbaLJEt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:49:59 -0500
In-Reply-To: <20141209203007.188651df@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 9 Dec 2014 20:30:07 -0800

> This reverts commit 66f1c44887ba4f47d617f8ae21cf8e04e1892bd7.
> 
> iproute2 uses sanitized kernel headers, and this change broke the build.
> The problem is that the iproute2 ip/iplink_bridge_slave.c include if_bridge.h
> but this causes a redefintion error when Glibc <netlink/in.h> is included.
> 
> Since iproute2 is arguably the most important user of network headers,
> the uapi header change should be reverted.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Stephen, please understand first the reason for this change.

GLIBC and the kernel fight over various definitions of core
networking types.

The only way to resolve this in the long term is this change
in question.

If you can make iproute2 work with both the new and the old
mechanims, please do so instead of reverting this important
change.

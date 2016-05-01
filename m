From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: l2tp: fix reversed udp6 checksum flags
Date: Sun, 01 May 2016 19:33:41 -0400 (EDT)
Message-ID: <20160501.193341.818074706429009741.davem@davemloft.net>
References: <9A325D67-FED1-4AF6-8ED0-6C93FFE8DC67@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, therbert@google.com
To: shankerwangmiao@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbcEAXdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 19:33:44 -0400
In-Reply-To: <9A325D67-FED1-4AF6-8ED0-6C93FFE8DC67@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Shanker <shankerwangmiao@gmail.com>
Date: Fri, 29 Apr 2016 01:29:43 +0800

> This patch fixes a bug which causes the behavior of whether to ignore
> udp6 checksum of udp6 encapsulated l2tp tunnel contrary to what
> userspace program requests.
> 
> When the flag `L2TP_ATTR_UDP_ZERO_CSUM6_RX` is set by userspace, it is
> expected that udp6 checksums of received packets of the l2tp tunnel
> to create should be ignored. In `l2tp_netlink.c`:
> `l2tp_nl_cmd_tunnel_create()`, `cfg.udp6_zero_rx_checksums` is set
> according to the flag, and then passed to `l2tp_core.c`:
> `l2tp_tunnel_create()` and then `l2tp_tunnel_sock_create()`. In
> `l2tp_tunnel_sock_create()`, `udp_conf.use_udp6_rx_checksums` is set
> the same to `cfg.udp6_zero_rx_checksums`. However, if we want the
> checksum to be ignored, `udp_conf.use_udp6_rx_checksums` should be set
> to `false`, i.e. be set to the contrary. Similarly, the same should be
> done to `udp_conf.use_udp6_tx_checksums`.
> 
> Signed-off-by: Miao Wang <shankerwangmiao@gmail.com>

Applied, thanks.

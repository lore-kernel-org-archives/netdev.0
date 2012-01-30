From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/tcp: Fix tcp memory limits initialization when
 !CONFIG_SYSCTL
Date: Mon, 30 Jan 2012 12:41:53 -0500 (EST)
Message-ID: <20120130.124153.637018079987753669.davem@davemloft.net>
References: <1327922417-9191-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu
To: glommer@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab2A3RmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:42:04 -0500
In-Reply-To: <1327922417-9191-1-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glauber Costa <glommer@parallels.com>
Date: Mon, 30 Jan 2012 15:20:17 +0400

> sysctl_tcp_mem() initialization was moved to sysctl_tcp_ipv4.c
> in commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334, since it
> became a per-ns value.
> 
> That code, however, will never run when CONFIG_SYSCTL is
> disabled, leading to bogus values on those fields - causing hung
> TCP sockets.
> 
> This patch fixes it by keeping an initialization code in
> tcp_init(). It will be overwritten by the first net namespace
> init if CONFIG_SYSCTL is compiled in, and do the right thing if
> it is compiled out.
> 
> It is also named properly as tcp_init_mem(), to properly signal
> its non-sysctl side effect on TCP limits.
> 
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: David S. Miller <davem@davemloft.net>
> Link: http://lkml.kernel.org/r/4F22D05A.8030604@parallels.com
> [ renamed the function, tidied up the changelog a bit ]
> Signed-off-by: Ingo Molnar <mingo@elte.hu>

Applied, thanks everyone.

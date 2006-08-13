From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] fix use after free in netlink_kernel_create()
Date: Sun, 13 Aug 2006 10:44:05 -0700
Message-ID: <20060813104405.a5c8db00.akpm@osdl.org>
References: <20060813101535.GA8703@miraclelinux.com>
	<44DF129A.6060607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35046 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751352AbWHMRoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 13:44:16 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44DF129A.6060607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Aug 2006 13:52:58 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Akinobu Mita wrote:
> > This patch invalidates nl_table by setting NULL when netlink
> > initialization failed. Otherwise netlink_kernel_create() would
> > access nl_table which has already been freed.
> 
> 
> Quite a few users of netlink_kernel_create will panic when creating
> the socket fails (rtnetlink for example, which is always present),
> so you might as well call panic here directly.

That's a bit lame.  Panicing at do_initcalls() time is OK (something is
seriously screwed anyway) but we usually try to handle the ENOMEM nicely if
it happens at modprobe-time.

(It's all pretty theoretical anyway - reasonable-sized GFP_KERNEL
allocations don't fail).


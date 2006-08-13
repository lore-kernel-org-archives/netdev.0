From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] fix use after free in netlink_kernel_create()
Date: Sun, 13 Aug 2006 20:49:06 +0200
Message-ID: <44DF7422.2090904@trash.net>
References: <20060813101535.GA8703@miraclelinux.com>	<44DF129A.6060607@trash.net> <20060813104405.a5c8db00.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44240 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751340AbWHMSvL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 14:51:11 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060813104405.a5c8db00.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sun, 13 Aug 2006 13:52:58 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>Quite a few users of netlink_kernel_create will panic when creating
>>the socket fails (rtnetlink for example, which is always present),
>>so you might as well call panic here directly.
> 
> 
> That's a bit lame.  Panicing at do_initcalls() time is OK (something is
> seriously screwed anyway) but we usually try to handle the ENOMEM nicely if
> it happens at modprobe-time.


The users I looked at can't be built as modules (rtnetlink, genetlink,
audit subsystem), I'm not aware of any modules panicing on
netlink_kernel_create failure. But all of netlink, genetlink and
rtnetlink are always built-in when CONFIG_NET=y, so we might as well
panic here.


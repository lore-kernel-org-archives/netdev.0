From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix use after free in netlink_kernel_create()
Date: Sun, 13 Aug 2006 21:02:02 -0700 (PDT)
Message-ID: <20060813.210202.127668846.davem@davemloft.net>
References: <44DF129A.6060607@trash.net>
	<20060813104405.a5c8db00.akpm@osdl.org>
	<44DF7422.2090904@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, mita@miraclelinux.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62087
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751841AbWHNEBj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 00:01:39 -0400
To: kaber@trash.net
In-Reply-To: <44DF7422.2090904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 13 Aug 2006 20:49:06 +0200

> Andrew Morton wrote:
> > On Sun, 13 Aug 2006 13:52:58 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> >>Quite a few users of netlink_kernel_create will panic when creating
> >>the socket fails (rtnetlink for example, which is always present),
> >>so you might as well call panic here directly.
> > 
> > 
> > That's a bit lame.  Panicing at do_initcalls() time is OK (something is
> > seriously screwed anyway) but we usually try to handle the ENOMEM nicely if
> > it happens at modprobe-time.
> 
> The users I looked at can't be built as modules (rtnetlink, genetlink,
> audit subsystem), I'm not aware of any modules panicing on
> netlink_kernel_create failure. But all of netlink, genetlink and
> rtnetlink are always built-in when CONFIG_NET=y, so we might as well
> panic here.

Agreed.

netlink_proto_init() is a core_initcall(), we are pretty much in
an irrecoverable bind if that thing fails, so panic() is appropriate
here.


From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1, kernel 3.2.1] RTNETLINK adjusting values of
 min_ifinfo_dump_size
Date: Wed, 25 Jan 2012 21:36:09 -0500 (EST)
Message-ID: <20120125.213609.1699401522361877843.davem@davemloft.net>
References: <30372884.681327480899559.JavaMail.root@5-MeO-DMT.ynet.sk>
	<26709175.701327480995351.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <26709175.701327480995351.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Wed, 25 Jan 2012 09:43:15 +0100 (CET)

> From: Stefan Gula <steweg@gmail.com>
> 
> This patch extends the rtnetlink.c. The problem is that calcit, which
> returns the value min_ifinfo_dump_size, is called without ability to
> get device info as well (struct net_device *dev is not accessible from
> it). This create a problem if required size of struct sk_buff *skb is
> not enough big to comply with all data returned by fill_info function
> for the interface that required size can vary over time, e.g. some
> dynamic structures will be putted to skb like hlists or lists. To do
> this patch extends the do_setlink function with recalculating of
> min_ifinfo_dump_size accordingly to device type and get_size
> functions.
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>

This commit message is terrible, and the reason I know it's terrible
is because even after reading it I still had to go read the code
in order to understand what your change even does or why it's even
necessary.

How about this:

	Setting link parameters on a netdevice changes the value
	of if_nlmsg_size(), therefore it is necessary to recalculate
	min_ifinfo_dump_size.

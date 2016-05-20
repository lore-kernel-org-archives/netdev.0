From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: pegasus: remove unused variables and labels
Date: Fri, 20 May 2016 11:58:47 +0200
Message-ID: <2736625.RvDzKBHoOP@wuerfel>
References: <1463732595-3149399-1-git-send-email-arnd@arndb.de> <20160520093223.GJ21813@p310>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, oneukum@suse.com, linux@roeck-us.net
To: Petko Manolov <petkan@mip-labs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160520093223.GJ21813@p310>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 20 May 2016 12:32:23 Petko Manolov wrote:
> Guys, come on.  This code is not dead.  This code is executed every time an 
> ethernet packet is received.  It takes care of various error statistics. More 
> importantly, it sends the actual (reported by the adapter) packet length to the 
> network layer along with the packet.
> 
> This patch removes skb_put() and netif_rx() calls and effectively kills the RX 
> path.  Not to mention that the driver was not even compiled before sending the 
> patch upstream.
> 
> The only sensible, although cosmetic, change would be to replace:
> 
>         if (!count || count < 4)
> 
> with
> 
>         if (count < 4)
> 
> even though GCC takes care and it optimizes away "!count" condition.
> 
> Please revert this patch before Linus pulls from the network tree.
> 

Agreed. I failed to check the commit that introduced the warning for
the more serious problem.

Please revert e00be9e4d0ff, it just makes no sense.

	Arnd

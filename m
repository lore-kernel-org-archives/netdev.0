From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: call phy_scan_fixups() after PHY reset
Date: Tue, 17 Sep 2013 15:44:46 -0400 (EDT)
Message-ID: <20130917.154446.554384673039269498.davem@davemloft.net>
References: <201309140410.38396.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, laurent.pinchart+renesas@ideasonboard.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201309140410.38396.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 14 Sep 2013 04:10:37 +0400

> Sometimes the PHY reset that sh_eth_phy_start() does effects the PHY registers
> registers values of which are vital for the correct functioning of the driver.
> Unfortunately, the existing PHY platform fixup mechanism doesn't help  here as
> it only hooks PHY resets done by ioctl() calls. Calling phy_scan_fixups() from
> the driver helps here. With a proper platform fixup, this fixes NFS timeouts on
> the SH-Mobile Lager board. 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

The PHY layer is designed to naturally already take care of this kind of
thing.  I think that part of the problem is that you're fighting the
natural control flow the PHY layer provides.

When the phy_connect() is performed, what we end up doing is calling
phy_attach_direct() which invokes the ->probe() method of the driver
and then afterwards we do phy_init_hw() which takes care of doing
the fixup calls.

So if you really need to do a BMCR reset then run the fixups I'd like
you to look into making that happen within the provided control
flow rather than with an exceptional explicit call to run the fixups.

I'm willing to be convinced that this is a better or necessary approach
but you'll need to explain it to me.

Thanks.

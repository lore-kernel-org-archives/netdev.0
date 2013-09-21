From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ARM: shmobile: Lager: add Micrel KSZ8041 PHY fixup
Date: Sat, 21 Sep 2013 10:14:05 -0700
Message-ID: <20130921171400.GA3181@verge.net.au>
References: <201309140429.23474.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sh@vger.kernel.org, magnus.damm@gmail.com,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	laurent.pinchart+renesas@ideasonboard.com, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201309140429.23474.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 14, 2013 at 04:29:22AM +0400, Sergei Shtylyov wrote:
> Currently on the Lager board NFS timeouts/delays are seen when booting.  That
> turned out to happen because the SoC's ETH_LINK signal turns on and off after
> each packet.  It is connected to Micrel KSZ8041 PHY's LED0 signal. Ether LEDs
> on the Lager board are named LINK and ACTIVE which corresponds to non-default
> 01 setting of the PHY control register 1 bits 14-15. The 'sh_eth' driver resets
> the PHY when opening the network device, so we have to set the mentioned bits
> back to 01 from the default 00 value which causes bouncing of ETH_LINK.  That
> can be achieved using the PHY platform fixup mechanism if we also modify the
> driver to use it..
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> This patch is against the recent Linus' tree. Its effect on NFS issue depends
> on the 'sh_eth' driver patch I've posted earlier. 
> Simon, please update your 'master' and/or 'fixes' branches since currently it's
> impossible to apply fixes to your tree.
> 
>  arch/arm/mach-shmobile/board-lager.c |   27 ++++++++++++++++++++++++++-
>  1 file changed, 26 insertions(+), 1 deletion(-)

Thanks, I have rebased my tree and applied this change to
the fixes-for-v3.12 branch.

And I will push the new tree either in the next
half hour or some time next week - I have to jump on a plane shortly.


From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Fri, 28 Mar 2014 14:26:06 -0400 (EDT)
Message-ID: <20140328.142606.2032782733436495474.davem@davemloft.net>
References: <1395400154-25710-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	laurent.pinchart+renesas@ideasonboard.com
To: ben.dooks@codethink.co.uk
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1395400154-25710-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Fri, 21 Mar 2014 12:09:14 +0100

> The pm_rumtime work queue is causing the device to be suspended during
> initialisation, thus the initialisation may not be able to access registers
> properly. As the code is called from a work queue, it is possible that this
> is not seen from certain configurations/builds due to the asynchronos
> nature of the code.
> 
> Another issue has also been found where the network device registration
> calls back into the driver thus causing further pm_runtime calls that
> also caused issues with the MDIO bus code. This has now been checked
> and is the only place the MDIO can be called without the device open.
> 
> Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
> pm system does not suspend it during the probe() call and remove the
> now unnecessary pm_runtime_resume() call. Also add a call in the error
> path to call pm_runtime_disable().
> 
> This fixes the external abort that can cause /sbin/init or other such
> init processed to die.
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

What tree is this against?  It doesn't apply cleanly to 'net'.

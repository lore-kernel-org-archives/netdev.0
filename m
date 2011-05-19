From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/6] forcedeth: Acknowledge only interrupts that are
 being processed
Date: Thu, 19 May 2011 02:35:39 +0100
Message-ID: <1305768939.19966.177.camel@localhost>
References: <1305764080-24853-1-git-send-email-decot@google.com>
	 <1305764080-24853-4-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-net-upstream@google.com,
	Mike Ditto <mditto@google.com>
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305764080-24853-4-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-05-18 at 17:14 -0700, David Decotigny wrote:
> From: Mike Ditto <mditto@google.com>
> 
> This is to avoid a race, accidentally acknowledging an interrupt that
> we didn't notice and won't immediately process.  This is based solely
> on code inspection; it is not known if there was an actual bug here.
> 
> 
> Signed-off-by: David Decotigny <decot@google.com>
> ---
>  drivers/net/forcedeth.c |   13 ++++++++-----
>  1 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 7a6aa08..17e79de 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -3403,7 +3403,8 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
>  
>  	for (i = 0;; i++) {
>  		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
> -		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
> +		writel(events, base + NvRegMSIXIrqStatus);
> +		netdev_dbg(dev, "%s: tx irq: %08x\n", dev->name, events);
[...]

netdev_dbg() and related logging functions already include the device
name, too. :-)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

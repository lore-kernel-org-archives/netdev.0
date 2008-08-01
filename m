From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 03/10] fs-enet: remove code associated with
	!CONFIG_PPC_MERGE
Date: Fri, 1 Aug 2008 13:57:14 -0500
Message-ID: <20080801185714.GA26062@ld0162-tx32.am.freescale.net>
References: <1217609060-6381-1-git-send-email-galak@kernel.crashing.org>
	<1217609060-6381-2-git-send-email-galak@kernel.crashing.org>
	<1217609060-6381-3-git-send-email-galak@kernel.crashing.org>
	<1217609060-6381-4-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1217609060-6381-4-git-send-email-galak@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 01, 2008 at 11:44:13AM -0500, Kumar Gala wrote:
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
> index 9a51ec8..e54d003 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -669,7 +669,6 @@ static int fs_request_irq(struct net_device *dev, int irq, const char *name,
>  {
>  	struct fs_enet_private *fep = netdev_priv(dev);
>  
> -	(*fep->ops->pre_request_irq)(dev, irq);
>  	return request_irq(irq, irqf, IRQF_SHARED, name, dev);
>  }

This makes "fep" an unused variable.  Eliminate this function entirely,
and call request_irq directly from the caller.

>  
> @@ -678,7 +677,6 @@ static void fs_free_irq(struct net_device *dev, int irq)
>  	struct fs_enet_private *fep = netdev_priv(dev);
>  
>  	free_irq(irq, dev);
> -	(*fep->ops->post_free_irq)(dev, irq);
>  }

Likewise.

-Scott

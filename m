From: "Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [ipw3945-devel] [PATCH 2/5] iwlwifi: iwl3945 synchronize interruptand tasklet for down iwlwifi
Date: Thu, 10 Jan 2008 11:10:35 -0800
Message-ID: <D936D925018D154694D8A362EEB08920035CCD70@orsmsx416.amr.corp.intel.com>
References: <11998765481610-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"lkml" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "Joonwoo Park" <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Zhu, Yi" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <11998765481610-git-send-email-joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On , Joonwoo Park  wrote:

> --- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> +++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> @@ -6262,6 +6262,10 @@ static void __iwl_down(struct iwl_priv *priv)
> 	/* tell the device to stop sending interrupts */
> 	iwl_disable_interrupts(priv);
> 
> +	/* synchronize irq and tasklet */
> +	synchronize_irq(priv->pci_dev->irq);
> +	tasklet_kill(&priv->irq_tasklet);
> +

Could synchronize_irq() be moved into iwl_disable_interrupts() ? I am
also wondering if we cannot call tasklet_kill() before
iwl_disable_interrupts() ... thus preventing it from being scheduled
when we are going down. 

Reinette

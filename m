From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 13:29:19 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52057B3B27@orsmsx418.amr.corp.intel.com>
References: <20080625141511.GH22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>
To: "Andy Gospodarek" <andy@greyhouse.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080625141511.GH22981@gospo.rdu.redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> Globally disable the interrupt during netpoll rather than simply
> disabling it on the hardware.  This will ensure all pending operations
> are complete and no more will execute.  I've seen reports of deadlocks
> with the current driver and this patch resolves them.

I agree this patch is probably okay, and if it fixes a specific problem
should be accepted however I have a question that didn't apply when we
originally created code like this.

> @@ -4024,7 +4024,7 @@ static void igb_netpoll(struct net_device
>  	*netdev) int i;
>  	int work_done = 0;
> 
> -	igb_irq_disable(adapter);
> +	disable_irq(adapter->pdev->irq);

how does changing to disable_irq/enable_irq work with MSI and MSI-X
interrupts?

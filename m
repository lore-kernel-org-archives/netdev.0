From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up.
Date: Wed, 4 Dec 2013 10:48:17 +0000
Message-ID: <alpine.DEB.2.02.1312041047200.7093@kaball.uk.xensource.com>
References: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <stefano.stabellini@eu.citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<leosilva@linux.vnet.ibm.com>, <ashley@ashleylai.com>,
	<peterhuewe@gmx.de>, <mail@srajiv.net>, <tpmdd@selhorst.net>,
	<tpmdd@sirrix.com>, <dmitry.torokhov@gmail.com>,
	<bhelgaas@google.com>, <plagnioj@jcrosoft.com>,
	<tomi.valkeinen@ti.com>, <tpmdd-devel@lists.sourceforge.net>,
	<linux-input@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-fbdev@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Dec 2013, Konrad Rzeszutek Wilk wrote:
> diff --git a/arch/x86/xen/platform-pci-unplug.c b/arch/x86/xen/platform-pci-unplug.c
> index 0a78524..087dfeb 100644
> --- a/arch/x86/xen/platform-pci-unplug.c
> +++ b/arch/x86/xen/platform-pci-unplug.c
> @@ -69,6 +69,24 @@ static int check_platform_magic(void)
>  	return 0;
>  }
>  
> +bool xen_has_pv_devices(void)
> +{
> +	if (!xen_domain())
> +		return false;
> +
> +	if (xen_hvm_domain()) {
> +		/* User requested no unplug, so no PV drivers. */
> +		if (xen_emul_unplug & XEN_UNPLUG_NEVER)
> +			return false;

Considering that if (xen_emul_unplug & XEN_UNPLUG_NEVER) we never set
xen_platform_pci_unplug, this check is redundant.


> +		/* And user has xen_platform_pci=0 set in guest config as
> +		 * driver did not modify the value. */
> +		if (!xen_platform_pci_unplug)
> +			return false;
> +	}
> +	return true;
> +}
> +EXPORT_SYMBOL_GPL(xen_has_pv_devices);
> +
>  void xen_unplug_emulated_devices(void)
>  {
>  	int r;

From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH RFC 06/77] PCI/MSI: Factor out pci_get_msi_cap()
 interface
Date: Thu, 3 Oct 2013 22:52:54 +0100
Message-ID: <1380837174.3419.21.camel@bwh-desktop.uk.level5networks.com>
References: <cover.1380703262.git.agordeev@redhat.com>
	 <9c282c4ab92731c719d161d2db6fc54ce33891d9.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	Michael Ellerman <michael-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andy King <acking-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>, Jon Mason <jon.mason-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Matt Porter <mporter-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	<linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	<linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, <linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	<linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <iss_storagedev-VXdhtT5mjnY@public.gmane.org>,
	<linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	<linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare
To: Alexander Gordeev <agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9c282c4ab92731c719d161d2db6fc54ce33891d9.1380703262.git.agordeev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-02 at 12:48 +0200, Alexander Gordeev wrote:
[...]
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -812,6 +812,21 @@ static int pci_msi_check_device(struct pci_dev *dev, int nvec, int type)
>  	return 0;
>  }
>  
> +int pci_get_msi_cap(struct pci_dev *dev)
> +{
> +	int ret;
> +	u16 msgctl;
> +
> +	if (!dev->msi_cap)
> +		return -EINVAL;
[...]
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1144,6 +1144,11 @@ struct msix_entry {
>  
> 
>  #ifndef CONFIG_PCI_MSI
> +static inline int pci_get_msi_cap(struct pci_dev *dev)
> +{
> +	return -1;
[...]

Shouldn't this also return -EINVAL?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

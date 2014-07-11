From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH 1/2 V2] PCI: introduce device assignment interface and
 refactory related code
Date: Fri, 11 Jul 2014 10:41:18 +0100
Message-ID: <53BFB13E.1060505@citrix.com>
References: <1405057961-7234-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-pci@vger.kernel.org>, <kvm@vger.kernel.org>,
	<linux.nics@intel.com>, <e1000-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ethan.kernel@gmail.com>, <vaughan.cao@oracle.com>
To: Ethan Zhao <ethan.zhao@oracle.com>, <bhelgaas@google.com>,
	<konrad.wilk@oracle.com>, <boris.ostrovsky@oracle.com>,
	<gleb@kernel.org>, <pbonzini@redhat.com>,
	<jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<bruce.w.allan@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <gregory.v.rose@intel.com>,
	<alexander.h.duyck@intel.com>, <john.ronciak@intel.com>,
	<mitch.a.williams@intel.com>, <alex.williamson@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1405057961-7234-1-git-send-email-ethan.zhao@oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/07/14 06:52, Ethan Zhao wrote:
> 
> --- a/drivers/xen/xen-pciback/pci_stub.c
> +++ b/drivers/xen/xen-pciback/pci_stub.c
> @@ -133,7 +133,7 @@ static void pcistub_device_release(struct kref *kref)
>  	xen_pcibk_config_free_dyn_fields(dev);
>  	xen_pcibk_config_free_dev(dev);
>  
> -	dev->dev_flags &= ~PCI_DEV_FLAGS_ASSIGNED;
> +	pci_sriov_deassign_device(dev);
>  	pci_dev_put(dev);
>  
>  	kfree(psdev);
> @@ -404,7 +404,7 @@ static int pcistub_init_device(struct pci_dev *dev)
>  	dev_dbg(&dev->dev, "reset device\n");
>  	xen_pcibk_reset_device(dev);
>  
> -	dev->dev_flags |= PCI_DEV_FLAGS_ASSIGNED;
> +	pci_sriov_assign_device(dev);
>  	return 0;

Xen's PCI passthrough works with all PCI devices not just SR-IOV ones,
so the naming of the helpers isn't correct.

David

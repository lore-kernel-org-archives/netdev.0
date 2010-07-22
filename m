From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V3] Export SMBIOS provided firmware instance and label
 to sysfs
Date: Thu, 22 Jul 2010 11:56:03 -0700
Message-ID: <20100722185603.GA2193@kroah.com>
References: <20100722184448.GA9122@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:55028 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755198Ab0GVS42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 14:56:28 -0400
Content-Disposition: inline
In-Reply-To: <20100722184448.GA9122@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 01:44:48PM -0500, Narendra K wrote:
> Hello,
> 
> Resubmitting the patch with suggested changes -
> 
> V2 -> V3:
> 
> 1. Added documentation about the sysfs attributes in Documentation/ABI
> directory.
> 2. Changed the type of parameter 'attribute' of the function
> 'find_smbios_instance_string' from int to enum.
> 3. Changed the return type of the functions 'pci_create_firmware_label_files'
> and 'pci_remove_firmware_label_files' from int to void
> 
> Please find the patch with above changes -
> 
>  
> From: Narendra K <narendra_k@dell.com>
> Subject: [PATCH] Export SMBIOS provided firmware instance and label to sysfs
> 
> This patch exports SMBIOS provided firmware instance and label
> of onboard pci devices to sysfs
> 
> Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
> Signed-off-by: Narendra K <narendra_k@dell.com>
> ---
>  Documentation/ABI/testing/sysfs-bus-pci |   26 ++++++
>  drivers/firmware/dmi_scan.c             |   25 ++++++
>  drivers/pci/Makefile                    |    3 +
>  drivers/pci/pci-label.c                 |  143 +++++++++++++++++++++++++++++++
>  drivers/pci/pci-sysfs.c                 |    5 +
>  drivers/pci/pci.h                       |    9 ++
>  include/linux/dmi.h                     |    9 ++
>  7 files changed, 220 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/pci/pci-label.c
> 
> diff --git a/Documentation/ABI/testing/sysfs-bus-pci b/Documentation/ABI/testing/sysfs-bus-pci
> index 428676c..d3eb807 100644
> --- a/Documentation/ABI/testing/sysfs-bus-pci
> +++ b/Documentation/ABI/testing/sysfs-bus-pci
> @@ -179,3 +179,29 @@ Contact:	linux-pci@vger.kernel.org
>  Description:
>  		This symbolic link points to the PCI hotplug controller driver
>  		module that manages the hotplug slot.
> +
> +What:		/sys/bus/pci/devices/.../label
> +Date:		July 2010
> +Contact:	Linux PCI developers <linux-pci@vger.kernel.org>

Why not contact you?

> +Description:
> +		Reading this attribute will provide the firmware
> +		given name of the PCI device. The attribute will
> +		be created only if the firmware has given a name
> +		to the PCI device.

Where does that "name" come from?  Please describe this.

> +Users:
> +		Userspace applications interested in knowing the
> +		firmware assigned name of the PCI device.
> +
> +What:		/sys/bus/pci/devices/.../index
> +Date:		July 2010
> +Contact:	Linux PCI developers <linux-pci@vger.kernel.org>
> +Description:
> +		Reading this attribute will provide the firmware
> +		given instance of the PCI device. The attribute will
> +		be created only if the firmware has given a device
> +		type instance to the PCI device.

Same comments as above.

thanks,

greg k-h

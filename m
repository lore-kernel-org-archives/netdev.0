From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] gt96100: stop using pci_find_device()
Date: Wed, 14 Sep 2005 15:00:58 -0400
Message-ID: <4328736A.8040803@pobox.com>
References: <20050914185136.GE19491@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20050914185136.GE19491@mipter.zuzino.mipt.ru>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> From: Scott Feldman <sfeldma@pobox.com>
> 
> Replace pci_find_device with pci_get_device/pci_dev_put to plug race
> with pci_find_device.
> 
> Signed-off-by: Scott Feldman <sfeldma@pobox.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  drivers/net/gt96100eth.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> --- a/drivers/net/gt96100eth.c
> +++ b/drivers/net/gt96100eth.c
> @@ -615,9 +615,9 @@ static int gt96100_init_module(void)
>  	/*
>  	 * Stupid probe because this really isn't a PCI device
>  	 */
> -	if (!(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
> +	if (!(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
>  	                            PCI_DEVICE_ID_MARVELL_GT96100, NULL)) &&
> -	    !(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
> +	    !(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
>  		                    PCI_DEVICE_ID_MARVELL_GT96100A, NULL))) {
>  		printk(KERN_ERR __FILE__ ": GT96100 not found!\n");
>  		return -ENODEV;
> @@ -627,12 +627,14 @@ static int gt96100_init_module(void)
>  	if (cpuConfig & (1<<12)) {
>  		printk(KERN_ERR __FILE__
>  		       ": must be in Big Endian mode!\n");
> +		pci_dev_put(pci);
>  		return -ENODEV;

NAK -- convert it to use standard PCI driver API.

	Jeff

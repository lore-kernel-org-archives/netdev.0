From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 11/26] janitor: net/tg3: pci_find_device to pci_dev_present
Date: Wed, 09 Mar 2005 15:25:42 -0500
Message-ID: <422F5BC6.9020802@pobox.com>
References: <20050306103312.3155B1E46E@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, sfeldma@pobox.com, janitor@sternwelten.at,
        "David S. Miller" <davem@davemloft.net>
To: domen@coderock.org
In-Reply-To: <20050306103312.3155B1E46E@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

domen@coderock.org wrote:
> Replace pci_find_device with pci_dev_present.  Compile tested.
> 
> Signed-off-by: Scott Feldman <sfeldma@pobox.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
> 
> 
>  kj-domen/drivers/net/tg3.c |   24 ++++++++++++++----------
>  1 files changed, 14 insertions(+), 10 deletions(-)
> 
> diff -puN drivers/net/tg3.c~remove-pci-find-device-drivers_net_tg3 drivers/net/tg3.c
> --- kj/drivers/net/tg3.c~remove-pci-find-device-drivers_net_tg3	2005-03-05 16:09:45.000000000 +0100
> +++ kj-domen/drivers/net/tg3.c	2005-03-05 16:09:45.000000000 +0100
> @@ -7829,6 +7829,19 @@ static int __devinit tg3_is_sun_570X(str
>  
>  static int __devinit tg3_get_invariants(struct tg3 *tp)
>  {
> +	static struct pci_device_id write_reorder_chipsets[] = {
> +		{ PCI_DEVICE(PCI_VENDOR_ID_INTEL,
> +		             PCI_DEVICE_ID_INTEL_82801AA_8) },
> +		{ PCI_DEVICE(PCI_VENDOR_ID_INTEL,
> +		             PCI_DEVICE_ID_INTEL_82801AB_8) },
> +		{ PCI_DEVICE(PCI_VENDOR_ID_INTEL,
> +		             PCI_DEVICE_ID_INTEL_82801BA_11) },
> +		{ PCI_DEVICE(PCI_VENDOR_ID_INTEL,
> +		             PCI_DEVICE_ID_INTEL_82801BA_6) },
> +		{ PCI_DEVICE(PCI_VENDOR_ID_AMD,
> +		             PCI_DEVICE_ID_AMD_FE_GATE_700C) },
> +		{ },
> +	};
>  	u32 misc_ctrl_reg;
>  	u32 cacheline_sz_reg;
>  	u32 pci_state_reg, grc_misc_cfg;
> @@ -7847,16 +7860,7 @@ static int __devinit tg3_get_invariants(
>  	 * every mailbox register write to force the writes to be
>  	 * posted to the chip in order.
>  	 */
> -	if (pci_find_device(PCI_VENDOR_ID_INTEL,
> -			    PCI_DEVICE_ID_INTEL_82801AA_8, NULL) ||
> -	    pci_find_device(PCI_VENDOR_ID_INTEL,
> -			    PCI_DEVICE_ID_INTEL_82801AB_8, NULL) ||
> -	    pci_find_device(PCI_VENDOR_ID_INTEL,
> -			    PCI_DEVICE_ID_INTEL_82801BA_11, NULL) ||
> -	    pci_find_device(PCI_VENDOR_ID_INTEL,
> -			    PCI_DEVICE_ID_INTEL_82801BA_6, NULL) ||
> -	    pci_find_device(PCI_VENDOR_ID_AMD,
> -			    PCI_DEVICE_ID_AMD_FE_GATE_700C, NULL))
> +	if (pci_dev_present(write_reorder_chipsets))
>  		tp->tg3_flags |= TG3_FLAG_MBOX_WRITE_REORDER;

seems OK to me.  DaveM should be applying this, though.

	Jeff

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.11-rc4-netdev1 5/5] r8169: literate PCI ID
Date: Tue, 22 Feb 2005 20:31:00 -0500
Message-ID: <421BDCD4.3050705@pobox.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com> <20050221235301.GA31723@electric-eye.fr.zoreil.com> <20050221235450.GB31723@electric-eye.fr.zoreil.com> <20050221235611.GC31723@electric-eye.fr.zoreil.com> <20050221235718.GD31723@electric-eye.fr.zoreil.com> <20050221235834.GE31723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050221235834.GE31723@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> De-obfuscate supported PCI ID
> 
> Non-hackers happen to read the sources too.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> diff -puN drivers/net/r8169.c~r8169-440 drivers/net/r8169.c
> --- a/drivers/net/r8169.c~r8169-440	2005-02-21 23:42:21.193570455 +0100
> +++ b/drivers/net/r8169.c	2005-02-21 23:42:21.200569312 +0100
> @@ -174,8 +174,10 @@ const static struct {
>  #undef _R
>  
>  static struct pci_device_id rtl8169_pci_tbl[] = {
> -	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> -	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> +	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8169,
> +	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
> +	{ PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE528T,
> +	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },

Although I leave it up to you as maintainer, I encourage use of 
PCI_VENDOR_ID_xxx and discourage use of PCI_DEVICE_ID_xxx.

Defining constants for each PCI device
(a) endlessly patches pci_ids.h for little value, and
(b) means that updates to a single driver are no longer self-contained.

For people pulling driver updates into distro kernels particularly, 
pci_ids PCI_DEVICE_ID_xxx constants are a pain.

I'm apply patches 1-4 to netdev right now -- please tell me if I should 
apply patch #5 as-is, given my comments here.

	Jeff

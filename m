From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 07/21] NTB: zero PCI driver data
Date: Sun, 20 Jan 2013 15:41:58 -0800
Message-ID: <20130120234158.GB14196@kroah.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-8-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358586155-23322-8-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 02:02:21AM -0700, Jon Mason wrote:
> Zero pci_device_id driver_data variable.  Unused, but 'EXTRA_CFLAGS=-W'
> complained of uninitialized variables.
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> ---
>  drivers/ntb/ntb_hw.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> index 0b46fef..867ccaa 100644
> --- a/drivers/ntb/ntb_hw.c
> +++ b/drivers/ntb/ntb_hw.c
> @@ -83,14 +83,14 @@ enum {
>  #define MW_TO_BAR(mw)	(mw * 2 + 2)
>  
>  static DEFINE_PCI_DEVICE_TABLE(ntb_pci_tbl) = {
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_BWD)},
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_JSF)},
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_JSF)},
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_JSF)},
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_SNB)},
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_SNB)},
> -	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_SNB)},
> -	{0}
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_BWD),		0},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_JSF),		0},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_JSF),	0},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_JSF),		0},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_RP_SNB),		0},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_B2B_SNB),		0},
> +	{PCI_VDEVICE(INTEL, PCI_DEVICE_ID_INTEL_NTB_CLASSIC_SNB),	0},
> +	{0, 0, 0, 0, 0, 0, 0}

Ick, why not just use PCI_DEVICE() instead?  Is it that hard to type out
the INTEL define?  That would, overall, look nicer than the 0, 0, 0...
line at the end, which is horrible (and not needed, { } is the same
thing.)

thanks,

greg k-h

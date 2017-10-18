From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: irda: resolve sparse errors due to implicit
 pci_power_t casts
Date: Wed, 18 Oct 2017 16:12:16 +0200
Message-ID: <20171018141216.GA6207@kroah.com>
References: <1507246703-1736-1-git-send-email-matthew@giassa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, devel@driverdev.osuosl.org,
        georgiana.chelu93@gmail.com, johannes.berg@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, khoroshilov@ispras.ru
To: Matthew Giassa <matthew@giassa.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507246703-1736-1-git-send-email-matthew@giassa.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 04:38:23PM -0700, Matthew Giassa wrote:
> Explicitly casting pci_power_t types to resolve sparse warnings (shown
> below).
> 
> Also fixing a related logging bug where pci_power_t is cast to unsigned
> (can be negative, i.e. PCI_POWER_ERROR).
> 
> Original sparse report:
> 
> drivers/staging/irda/drivers//vlsi_ir.c:170:51: warning: cast from
> restricted pci_power_t
> drivers/staging/irda/drivers//vlsi_ir.c:1726:39: warning: restricted
> pci_power_t degrades to integer
> drivers/staging/irda/drivers//vlsi_ir.c:1728:45: warning: incorrect type
> in assignment (different base types)
> drivers/staging/irda/drivers//vlsi_ir.c:1728:45:    expected restricted
> pci_power_t [usertype] current_state
> drivers/staging/irda/drivers//vlsi_ir.c:1728:45:    got int [signed]
> [usertype] event
> drivers/staging/irda/drivers//vlsi_ir.c:1748:29: warning: incorrect type
> in assignment (different base types)
> drivers/staging/irda/drivers//vlsi_ir.c:1748:29:    expected restricted
> pci_power_t [usertype] current_state
> drivers/staging/irda/drivers//vlsi_ir.c:1748:29:    got int [signed]
> [usertype] event

Please do not line-wrap lines like this, it makes them harder to
understand.

> 
> Warnings no longer present.
> 
> Signed-off-by: Matthew Giassa <matthew@giassa.net>
> ---
>  drivers/staging/irda/drivers/vlsi_ir.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/irda/drivers/vlsi_ir.c b/drivers/staging/irda/drivers/vlsi_ir.c
> index 3dff3c5..20ce4d8 100644
> --- a/drivers/staging/irda/drivers/vlsi_ir.c
> +++ b/drivers/staging/irda/drivers/vlsi_ir.c
> @@ -167,7 +167,8 @@ static void vlsi_proc_pdev(struct seq_file *seq, struct pci_dev *pdev)
>  
>  	seq_printf(seq, "\n%s (vid/did: [%04x:%04x])\n",
>  		   pci_name(pdev), (int)pdev->vendor, (int)pdev->device);
> -	seq_printf(seq, "pci-power-state: %u\n", (unsigned) pdev->current_state);
> +	seq_printf(seq, "pci-power-state: %d\n",
> +		   (int __force)pdev->current_state);

Ick, using __force is almost always a huge sign that something is wrong
here.  This patch does not look correct because of this.

You did read drivers/staging/irda/TODO, right?

thanks,

greg k-h

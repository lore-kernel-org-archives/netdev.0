From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 12/34] e1000e: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 22:17:18 +0300
Message-ID: <52EBF6BE.8000201@cogentembedded.com>
References: <cover.1391172839.git.agordeev@redhat.com> <0ec36309e17031a66d3a6ab489fc60702b6d76b3.1391172839.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <0ec36309e17031a66d3a6ab489fc60702b6d76b3.1391172839.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/31/2014 06:08 PM, Alexander Gordeev wrote:

> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.

> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> ---
>   drivers/net/ethernet/intel/e1000e/netdev.c |    9 +++++----
>   1 files changed, 5 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 6d91933..7735d1a 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -2041,10 +2041,11 @@ void e1000e_set_interrupt_capability(struct e1000_adapter *adapter)
>   				for (i = 0; i < adapter->num_vectors; i++)
>   					adapter->msix_entries[i].entry = i;
>
> -				err = pci_enable_msix(adapter->pdev,
> -						      adapter->msix_entries,
> -						      adapter->num_vectors);
> -				if (err == 0)
> +				err = pci_enable_msix_range(adapter->pdev,
> +							adapter->msix_entries,
> +							adapter->num_vectors,
> +							adapter->num_vectors);

    You should align all 'adapter' references under each other, according to 
networking coding rules.

WBR, Sergei

From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH 1/3] pci: fix return value from pcix_get_max_mmrbc()
Date: Fri, 19 Mar 2010 12:42:21 -0700
Message-ID: <20100319124221.13d3d914@jbarnes-piketon>
References: <20100310032632.6331.15414.send-patch@aqua>
	<20100310032640.6331.39506.send-patch@aqua>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Dean Nelson <dnelson@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100310032640.6331.39506.send-patch@aqua>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2010 22:26:40 -0500
Dean Nelson <dnelson@redhat.com> wrote:

> For the PCI_X_STATUS register, pcix_get_max_mmrbc() is returning an incorrect
> value, which is based on:
> 
> 	(stat & PCI_X_STATUS_MAX_READ) >> 12
> 
> Valid return values are 512, 1024, 2048, 4096, which correspond to a 'stat'
> (masked and right shifted by 21) of 0, 1, 2, 3, respectively.
> 
> A right shift by 11 would generate the correct return value when 'stat' (masked
> and right shifted by 21) has a value of 1 or 2. But for a value of 0 or 3 it's
> not possible to generate the correct return value by only right shifting.
> 
> Fix is based on pcix_get_mmrbc()'s similar dealings with the PCI_X_CMD register.
> 
> Signed-off-by: Dean Nelson <dnelson@redhat.com>
> 
> ---
> 
>  drivers/pci/pci.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 5b548ae..1decd4f 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -2571,7 +2571,7 @@ int pcix_get_max_mmrbc(struct pci_dev *dev)
>  	if (err)
>  		return -EINVAL;
>  
> -	return (stat & PCI_X_STATUS_MAX_READ) >> 12;
> +	return 512 << ((stat & PCI_X_STATUS_MAX_READ) >> 21);
>  }
>  EXPORT_SYMBOL(pcix_get_max_mmrbc);

Applied this series, thanks Dean.

-- 
Jesse Barnes, Intel Open Source Technology Center

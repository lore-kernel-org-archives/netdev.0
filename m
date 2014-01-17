From: ethan zhao <ethan.zhao@oracle.com>
Subject: Re: [Patch 2/2 net-next v6] ixgbe: set driver_max_VFs should be done
 before enabling SRIOV
Date: Fri, 17 Jan 2014 14:51:58 +0800
Message-ID: <52D8D30E.7090101@oracle.com>
References: <1389930065-3330-1-git-send-email-aaron.f.brown@intel.com> <1389930065-3330-3-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, ethan.kernel@gmail.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46523 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbaAQGwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 01:52:10 -0500
In-Reply-To: <1389930065-3330-3-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Great job. Thanks a lot.

Ethan

On 2014/1/17 11:41, Aaron Brown wrote:
> From: "ethan.zhao" <ethan.zhao@oracle.com>
>
> commit 43dc4e01 Limit number of reported VFs to device
>   specific value It doesn't work and always returns -EBUSY because VFs are
>   already enabled.
>
> ixgbe_enable_sriov()
>          pci_enable_sriov()
>                  sriov_enable()
>                  {
>                  ... ..
>                  iov->ctrl |= PCI_SRIOV_CTRL_VFE | PCI_SRIOV_CTRL_MSE;
>                  pci_cfg_access_lock(dev);
>                  ... ...
>                  }
>
> pci_sriov_set_totalvfs()
> {
> ... ...
> if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
>                  return -EBUSY;
> ...
> }
>
> So should set driver_max_VFs with pci_sriov_set_totalvfs() before
> enable VFs with ixgbe_enable_sriov().
>
> V2: revised for net-next tree.
>
> Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 3fd4d3f..61d985c 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -8019,8 +8019,8 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>   	/* Mailbox */
>   	ixgbe_init_mbx_params_pf(hw);
>   	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
> -	ixgbe_enable_sriov(adapter);
>   	pci_sriov_set_totalvfs(pdev, IXGBE_MAX_VFS_DRV_LIMIT);
> +	ixgbe_enable_sriov(adapter);
>   skip_sriov:
>   
>   #endif

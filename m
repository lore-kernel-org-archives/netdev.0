From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/5] driver/net: enic: Exposing symbols for
 Cisco's low latency driver
Date: Wed, 4 Sep 2013 15:52:56 +0100
Message-ID: <1378306376.3133.7.camel@bwh-desktop.uk.level5networks.com>
References: <1378273638-7780-1-git-send-email-govindarajulu90@gmail.com>
	 <1378273638-7780-5-git-send-email-govindarajulu90@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <benve@cisco.com>,
	<ssujith@cisco.com>, <nistrive@cisco.com>, <umalhi@cisco.com>
To: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378273638-7780-5-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-04 at 11:17 +0530, Govindarajulu Varadarajan wrote:
> This patch exposes symbols for usnic low latency driver that can be used to 
> register and unregister vNics as well to traverse the resources on vNics.
> 
> Signed-off-by: Upinder Malhi <umalhi@cisco.com>
> Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Will usnic, or any other user of these symbols, be submitted for
inclusion in-tree as well?  It is generally expected that exported
functions do have an in-tree user.

Also, header files under drivers/ generally won't be included in
distribution -devel packages, so to support an out-of-tree module the
function prototypes would need to be included in a header under include/
(or else you have to repeat them and hope the types never change).

Ben.

> ---
>  drivers/net/ethernet/cisco/enic/vnic_dev.c | 10 ++++++++++
>  drivers/net/ethernet/cisco/enic/vnic_dev.h |  1 +
>  2 files changed, 11 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
> index 97455c5..69dd925 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
> +++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
> @@ -175,6 +175,7 @@ unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
>  {
>  	return vdev->res[type].count;
>  }
> +EXPORT_SYMBOL(vnic_dev_get_res_count);
>  
>  void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
>  	unsigned int index)
> @@ -193,6 +194,7 @@ void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
>  		return (char __iomem *)vdev->res[type].vaddr;
>  	}
>  }
> +EXPORT_SYMBOL(vnic_dev_get_res);
>  
>  static unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
>  	unsigned int desc_count, unsigned int desc_size)
> @@ -942,6 +944,7 @@ void vnic_dev_unregister(struct vnic_dev *vdev)
>  		kfree(vdev);
>  	}
>  }
> +EXPORT_SYMBOL(vnic_dev_unregister);
>  
>  struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
>  	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
> @@ -969,6 +972,13 @@ err_out:
>  	vnic_dev_unregister(vdev);
>  	return NULL;
>  }
> +EXPORT_SYMBOL(vnic_dev_register);
> +
> +struct pci_dev *vnic_dev_get_pdev(struct vnic_dev *vdev)
> +{
> +	return vdev->pdev;
> +}
> +EXPORT_SYMBOL(vnic_dev_get_pdev);
>  
>  int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len)
>  {
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
> index f3d9b79..e670029 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
> +++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
> @@ -127,6 +127,7 @@ int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
>  struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
>  	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
>  	unsigned int num_bars);
> +struct pci_dev *vnic_dev_get_pdev(struct vnic_dev *vdev);
>  int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len);
>  int vnic_dev_enable2(struct vnic_dev *vdev, int active);
>  int vnic_dev_enable2_done(struct vnic_dev *vdev, int *status);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

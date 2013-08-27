From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [patch -next] qlcnic: underflow in
 qlcnic_validate_max_tx_rings()
Date: Tue, 27 Aug 2013 04:40:49 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311CC0C5@avmb3.qlogic.org>
References: <20130827011622.GB17061@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130827011622.GB17061@elgon.mountain>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Monday, August 26, 2013 6:16 PM
> To: Himanshu Madhani
> Cc: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko; Sucheta
> Chakraborty; Dept-Eng Linux Driver; netdev; kernel-janitors@vger.kernel.org
> Subject: [patch -next] qlcnic: underflow in qlcnic_validate_max_tx_rings()
> 
> This function checks the upper bound but it doesn't check for negative
> numbers:
> 
> 	if (txq > QLCNIC_MAX_TX_RINGS) {
> 
> I've solved this by making "txq" a u32 type.  I chose that because
> ->tx_count in the ethtool_channels struct is a __u32.
> 
> This bug was added in aa4a1f7df7 ('qlcnic: Enable Tx queue changes using
> ethtool for 82xx Series adapter.').
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> index 3f03856..ae9b444 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> @@ -1537,7 +1537,7 @@ int qlcnic_diag_alloc_res(struct net_device
> *netdev, int test);  netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb,
> struct net_device *netdev);  int qlcnic_set_max_rss(struct qlcnic_adapter *,
> u8, int);  int qlcnic_validate_max_rss(struct qlcnic_adapter *, __u32); -int
> qlcnic_validate_max_tx_rings(struct qlcnic_adapter *, int);
> +int qlcnic_validate_max_tx_rings(struct qlcnic_adapter *, u32 txq);
>  void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);  void
> qlcnic_82xx_set_mac_filter_count(struct qlcnic_adapter *);  int
> qlcnic_enable_msix(struct qlcnic_adapter *, u32); diff --git
> a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 8321d1a..88e3c97 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -3524,7 +3524,7 @@ qlcnicvf_start_firmware(struct qlcnic_adapter
> *adapter)
>  	return err;
>  }
> 
> -int qlcnic_validate_max_tx_rings(struct qlcnic_adapter *adapter, int txq)
> +int qlcnic_validate_max_tx_rings(struct qlcnic_adapter *adapter, u32
> +txq)
>  {
>  	struct net_device *netdev = adapter->netdev;
>  	u8 max_hw = QLCNIC_MAX_TX_RINGS;

Thanks

Acked-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

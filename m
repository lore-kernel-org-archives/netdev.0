From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH] net: hns3: fix null pointer dereference before null check
Date: Sat, 30 Sep 2017 08:43:34 +0800
Message-ID: <b8f17467-71f6-688c-a18e-64c1e6dc0b89@huawei.com>
References: <20170929195123.4189-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kernel-janitors@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929195123.4189-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Colin

On 2017/9/30 3:51, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> pointer ndev is being dereferenced with the call to netif_running
> before it is being null checked.  Re-order the code to only dereference
> ndev after it has been null checked.

Thanks for fixing it.

> 
> Detected by CoverityScan, CID#1457206 ("Dereference before null check")
> 
> Fixes: 9df8f79a4d29 ("net: hns3: Add DCB support when interacting with network stack")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> index 4a0890f98b70..c31506514e5d 100644
> --- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> @@ -2865,7 +2865,7 @@ static int hns3_client_setup_tc(struct hnae3_handle *handle, u8 tc)
>  {
>  	struct hnae3_knic_private_info *kinfo = &handle->kinfo;
>  	struct net_device *ndev = kinfo->netdev;
> -	bool if_running = netif_running(ndev);
> +	bool if_running;
>  	int ret;
>  	u8 i;
>  
> @@ -2875,6 +2875,8 @@ static int hns3_client_setup_tc(struct hnae3_handle *handle, u8 tc)
>  	if (!ndev)
>  		return -ENODEV;
>  
> +	if_running = netif_running(ndev);
> +
>  	ret = netdev_set_num_tc(ndev, tc);
>  	if (ret)
>  		return ret;
> 

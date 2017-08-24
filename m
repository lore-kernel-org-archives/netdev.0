From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net-next/hinic: Fix MTU limitation
Date: Thu, 24 Aug 2017 17:19:58 +0200
Message-ID: <20170824151958.GL8022@lunn.ch>
References: <1503580885-35180-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, zhaochen6@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43180 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751352AbdHXPUB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 11:20:01 -0400
Content-Disposition: inline
In-Reply-To: <1503580885-35180-1-git-send-email-aviad.krawczyk@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 09:21:25PM +0800, Aviad Krawczyk wrote:
> Fix the hw MTU limitation by setting min/max_mtu
> 
> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
> Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
> ---
>  drivers/net/ethernet/huawei/hinic/hinic_main.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
> index ae7ad48..7a14963 100644
> --- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
> +++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
> @@ -980,6 +980,9 @@ static int nic_dev_init(struct pci_dev *pdev)
>  	hinic_hwdev_cb_register(nic_dev->hwdev, HINIC_MGMT_MSG_CMD_LINK_STATUS,
>  				nic_dev, link_status_event_handler);
>  
> +	netdev->min_mtu = ETH_MIN_MTU;

You don't need to set the min_mtu. See:

http://elixir.free-electrons.com/linux/latest/source/net/ethernet/eth.c#L354

	Andrew

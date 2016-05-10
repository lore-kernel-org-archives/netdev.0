From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] drivers: net: Don't print unpopulated net_device
 name
Date: Tue, 10 May 2016 11:31:48 -0700
Message-ID: <20160510113148.4b4d0d6d@xeon-e3>
References: <1462898601-5429-1-git-send-email-harvey.hunt@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Robert Jarzmik <robert.jarzmik@free.fr>,
	Barry Song <Baohua.Song@csr.com>,
	Marcel Ziswiler <marcel@ziswiler.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Harvey Hunt <harvey.hunt@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462898601-5429-1-git-send-email-harvey.hunt@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 May 2016 17:43:21 +0100
Harvey Hunt <harvey.hunt@imgtec.com> wrote:

> For ethernet devices, net_device.name will be eth%d before
> register_netdev() is called. Don't print the net_device name until
> the format string is replaced.
> 
> Cc: Robert Jarzmik <robert.jarzmik@free.fr>
> Cc: Barry Song <Baohua.Song@csr.com>
> Cc: Marcel Ziswiler <marcel@ziswiler.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> 
> Signed-off-by: Harvey Hunt <harvey.hunt@imgtec.com>
> ---
> I've tested this patch on a board that has a DM9000, but haven't 
> tested the other two network devices.
> 
>  drivers/net/ethernet/davicom/dm9000.c   | 3 +--
>  drivers/net/ethernet/micrel/ks8695net.c | 3 +--
>  drivers/net/ethernet/netx-eth.c         | 3 +--
>  3 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index 48d9194..89dcaa1 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
> @@ -1686,8 +1686,7 @@ dm9000_probe(struct platform_device *pdev)
>  	}
>  
>  	if (!is_valid_ether_addr(ndev->dev_addr)) {
> -		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
> -			 "set using ifconfig\n", ndev->name);
> +		dev_warn(db->dev, "Invalid ethernet MAC address. Please set using ifconfig\n");

ifconfig is deprecated, therefore please don't tell users to use it.

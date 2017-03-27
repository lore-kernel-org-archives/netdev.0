From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] netvsc: fix unititialized return value in variable ret
Date: Mon, 27 Mar 2017 00:52:38 +0000
Message-ID: <BLUPR03MB14128BF9E77DB2E22206F99ACA330@BLUPR03MB1412.namprd03.prod.outlook.com>
References: <20170325141653.11238-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>, KY Srinivasan <kys@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170325141653.11238-1-colin.king@canonical.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Colin King [mailto:colin.king@canonical.com]
> Sent: Saturday, March 25, 2017 10:17 AM
> To: KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; Stephen Hemminger <sthemmin@microsoft.com>;
> devel@linuxdriverproject.org; netdev@vger.kernel.org
> Cc: kernel-janitors@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] netvsc: fix unititialized return value in variable ret
> 
> From: Colin Ian King <colin.king@canonical.com>
> 
> It is possible for an uninitialized value of ret to be returned
> so fix this by initializing ret to zero.
> 
> Detected by CoverityScan, CID#1420762 ("Uninitialized scalar variable")
> 
> Fixes: 163891d7d429 ("netvsc: handle offline mtu and channel change")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c
> b/drivers/net/hyperv/netvsc_drv.c
> index eb7ae79d47bb..f830bbbd8ad4 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -855,7 +855,7 @@ static int netvsc_change_mtu(struct net_device *ndev,
> int mtu)
>  	struct hv_device *hdev = ndevctx->device_ctx;
>  	struct netvsc_device_info device_info;
>  	bool was_running;
> -	int ret;
> +	int ret = 0;

This was just fix by commit: 386f57622cc3bbb39b9c00fc8762bc9ab28e0f8d

Thanks.

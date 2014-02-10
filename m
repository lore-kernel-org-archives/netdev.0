From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] hyperv: Fix the carrier status setting
Date: Mon, 10 Feb 2014 17:28:55 +0400
Message-ID: <52F8D417.6020302@cogentembedded.com>
References: <1391994478-25809-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: driverdev-devel@linuxdriverproject.org, olaf@aepfle.de, jasowang@redhat.com,
 linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net,
 netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391994478-25809-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Hello.

On 10-02-2014 5:07, Haiyang Zhang wrote:

> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>   drivers/net/hyperv/netvsc_drv.c |   24 +++++++++++++++---------
>   1 files changed, 15 insertions(+), 9 deletions(-)

> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 7756118..836211c 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
[...]
> @@ -229,15 +238,17 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
>   	struct net_device *net;
>   	struct net_device_context *ndev_ctx;
>   	struct netvsc_device *net_device;
> +	struct rndis_device *rdev;
>
>   	net_device = hv_get_drvdata(device_obj);
> +	rdev = net_device->extension;
> +
> +	rdev->link_state = !(status == 1);

    Why not just 'status != 1'?

WBR, Sergei

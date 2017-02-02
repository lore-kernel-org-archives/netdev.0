From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: ethernet: bgmac: mac address change bug
Date: Thu, 2 Feb 2017 12:49:59 +0300
Message-ID: <bb8075a0-a8cb-f3a2-19bb-d36e473ec509@cogentembedded.com>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Hari Vyas <hariv@broadcom.com>
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485988752-21030-3-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/2/2017 1:39 AM, Jon Mason wrote:

> From: Hari Vyas <hariv@broadcom.com>
>
> ndo_set_mac_address() passes struct sockaddr * as 2nd parameter to
> bgmac_set_mac_address() but code assumed u8 *.  This caused two bytes
> chopping and the wrong mac address was configured.
>
> Signed-off-by: Hari Vyas <hariv@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 4e209001b86 ("bgmac: write mac address to hardware in ndo_set_mac_address")
> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 0e066dc6..ea24072 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1222,11 +1222,15 @@ static int bgmac_set_mac_address(struct net_device *net_dev, void *addr)
>  {
>  	struct bgmac *bgmac = netdev_priv(net_dev);
>  	int ret;
> +	struct sockaddr *sa = addr;

    DaveM prefers the declarations to be arranged from longest to shortest.

[...]

MBR, Sergei

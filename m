From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] davinci_emac.c: Fix IFF_ALLMULTI setup
Date: Mon, 21 Oct 2013 21:27:40 +0400
Message-ID: <5265640C.4070201@cogentembedded.com>
References: <1382374777-24200-1-git-send-email-mceier+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mariusz Ceier <mceier+kernel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Lad Prabhakar <prabhakar.csengg@gmail.com>,
	Jingoo Han <jg1.han@samsung.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382374777-24200-1-git-send-email-mceier+kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/21/2013 08:59 PM, Mariusz Ceier wrote:

> When IFF_ALLMULTI flag is set on interface and IFF_PROMISC isn't,
> emac_dev_mcast_set should only enable RX of multicasts and reset
> MACHASH registers.

> It does this, but afterwards it either sets up multicast MACs
> filtering or disables RX of multicasts and resets MACHASH registers
> again, rendering IFF_ALLMULTI flag useless.

> This patch fixes emac_dev_mcast_set, so that multicast MACs filtering and
> disabling of RX of multicasts are skipped when IFF_ALLMULTI flag is set.

> Tested with kernel 2.6.37.

> Signed-off-by: Mariusz Ceier <mceier+kernel@gmail.com>
> ---
>   drivers/net/ethernet/ti/davinci_emac.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index 67df09e..ff3bf0e 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -876,7 +876,7 @@ static void emac_dev_mcast_set(struct net_device *ndev)
>   		    netdev_mc_count(ndev) > EMAC_DEF_MAX_MULTICAST_ADDRESSES) {
>   			mbp_enable = (mbp_enable | EMAC_MBP_RXMCAST);
>   			emac_add_mcast(priv, EMAC_ALL_MULTI_SET, NULL);
> -		}
> +		} else
>   		if (!netdev_mc_empty(ndev)) {

    It should be:

		} else if (!netdev_mc_empty(ndev)) {

WBR, Sergei

From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/1] net: thunderx: avoid null pointer dereference
Date: Tue, 17 May 2016 13:21:13 -0700
Message-ID: <573B7D39.9050305@caviumnetworks.com>
References: <1463514038-9008-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463514038-9008-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2016 12:40 PM, Heinrich Schuchardt wrote:
> In function bgx_lmac_handler only use a member of
> lmac after checking it is not null.
>

Were you seeing and actual OOPs, or is this only a theoretical problem 
flagged by some sort of static code checker?

> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

In any event, it seems sane to make this change, so:

Acked-by: David Daney <david.daney@cavium.com>


> ---
>   drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index d20539a..3ed2198 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> @@ -274,12 +274,14 @@ static void bgx_sgmii_change_link_state(struct lmac *lmac)
>   static void bgx_lmac_handler(struct net_device *netdev)
>   {
>   	struct lmac *lmac = container_of(netdev, struct lmac, netdev);
> -	struct phy_device *phydev = lmac->phydev;
> +	struct phy_device *phydev;
>   	int link_changed = 0;
>
>   	if (!lmac)
>   		return;
>
> +	phydev = lmac->phydev;
> +
>   	if (!phydev->link && lmac->last_link)
>   		link_changed = -1;
>
>

From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH RFC v1 7/7] net: cpsw: resume/suspend PHY on port
 start/stop
Date: Thu, 21 Nov 2013 14:05:41 +0530
Message-ID: <528DC5DD.8040801@ti.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1384978913-8052-8-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1384978913-8052-8-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thursday 21 November 2013 01:51 AM, Sebastian Hesselbarth wrote:
> Network PHYs consume a noticable amount of power. This adds phy_resume
> on slave_open and phy_suspend on slave_stop to save this power if the
> port is down anyway.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/ethernet/ti/cpsw.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 90d41d2..f1dc54f 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1013,6 +1013,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>  	} else {
>  		dev_info(priv->dev, "phy found : id is : 0x%x\n",
>  			 slave->phy->phy_id);
> +		phy_resume(slave->phy);
>  		phy_start(slave->phy);
>  
>  		/* Configure GMII_SEL register */
> @@ -1081,6 +1082,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
>  	if (!slave->phy)
>  		return;
>  	phy_stop(slave->phy);
> +	phy_suspend(slave->phy);
>  	phy_disconnect(slave->phy);
>  	slave->phy = NULL;
>  }

Can these be called from phy_start and phy_stop itself so that it
reduces the effort of patching all drivers and also applies to all
etherent drivers.

Regards
Mugunthan V N

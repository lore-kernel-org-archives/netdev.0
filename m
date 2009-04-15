From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 09/14] net: Rework gianfar driver to use of_mdio
	infrastructure.
Date: Wed, 15 Apr 2009 18:01:17 -0500
Message-ID: <E3135C12-C512-43CF-B30D-B3AF7D7DE181@freescale.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331082730.1427.96418.stgit@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, olof@lixom.net
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090331082730.1427.96418.stgit@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Mar 31, 2009, at 3:27 AM, Grant Likely wrote:

> From: Grant Likely <grant.likely@secretlab.ca>
>
> This patch simplifies the driver by making use of more common code.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> drivers/net/gianfar.c |  103 +++++++++++++++++ 
> +-------------------------------
> drivers/net/gianfar.h |    3 +
> 2 files changed, 40 insertions(+), 66 deletions(-)
>
>
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 65f5587..c22eba9 100644
> @@ -699,23 +657,38 @@ static int init_phy(struct net_device *dev)
>
>
> +	if (priv->tbi_node) {
> +		priv->tbiphy = of_phy_connect(dev, priv->tbi_node, &adjust_link,
> +					      0, interface);
> +		if (!priv->tbiphy) {
> +			dev_err(&dev->dev, "error: Could not attach to TBI\n");
> +			goto err_tbiphy;
> +		}
> +	}

I don't believe we need this.  Certainly, the current code doesn't do  
anything like this.  The TBI node is a special internal PHY used to  
manage SGMII/TBI links.


Andy

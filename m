From: Rafal Milecki <rafal@milecki.pl>
Subject: Re: [PATCH v5 5/7] net: ethernet: bgmac: device tree phy enablement
Date: Thu, 3 Nov 2016 09:31:21 +0100
Message-ID: <35b16640-8600-8c48-2f04-886dc925229d@milecki.pl>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-6-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 devicetree@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, David Miller <davem@davemloft.net>,
 Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1478106488-11779-6-git-send-email-jon.mason@broadcom.com>
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

On 11/02/2016 06:08 PM, Jon Mason wrote:
> Change the bgmac driver to allow for phy's defined by the device tree

This is a late review, I know, sorry... :(


> +static int bcma_phy_direct_connect(struct bgmac *bgmac)
> +{
> +	struct fixed_phy_status fphy_status = {
> +		.link = 1,
> +		.speed = SPEED_1000,
> +		.duplex = DUPLEX_FULL,
> +	};
> +	struct phy_device *phy_dev;
> +	int err;
> +
> +	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
> +	if (!phy_dev || IS_ERR(phy_dev)) {
> +		dev_err(bgmac->dev, "Failed to register fixed PHY device\n");
> +		return -ENODEV;
> +	}
> +
> +	err = phy_connect_direct(bgmac->net_dev, phy_dev, bgmac_adjust_link,
> +				 PHY_INTERFACE_MODE_MII);
> +	if (err) {
> +		dev_err(bgmac->dev, "Connecting PHY failed\n");
> +		return err;
> +	}
> +
> +	return err;
> +}

This bcma specific function looks exactly the same as...


> +static int platform_phy_direct_connect(struct bgmac *bgmac)
> +{
> +	struct fixed_phy_status fphy_status = {
> +		.link = 1,
> +		.speed = SPEED_1000,
> +		.duplex = DUPLEX_FULL,
> +	};
> +	struct phy_device *phy_dev;
> +	int err;
> +
> +	phy_dev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
> +	if (!phy_dev || IS_ERR(phy_dev)) {
> +		dev_err(bgmac->dev, "Failed to register fixed PHY device\n");
> +		return -ENODEV;
> +	}
> +
> +	err = phy_connect_direct(bgmac->net_dev, phy_dev, bgmac_adjust_link,
> +				 PHY_INTERFACE_MODE_MII);
> +	if (err) {
> +		dev_err(bgmac->dev, "Connecting PHY failed\n");
> +		return err;
> +	}
> +
> +	return err;
> +}

This one.

Would that make sense to keep bgmac_phy_connect_direct and just use it in
bcma/platform code?

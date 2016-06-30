From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 5/7] net: ethernet: bgmac: Add platform device support
Date: Thu, 30 Jun 2016 16:26:00 -0700
Message-ID: <5775AA88.60800@gmail.com>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
 <1467327554-22074-6-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Scott Branden <sbranden@broadcom.com>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, hauke@hauke-m.de,
 linux-kernel@vger.kernel.org, Ray Jui <rjui@broadcom.com>,
 Rob Herring <robh+dt@kernel.org>, bcm-kernel-feedback-list@broadcom.com,
 Kumar Gala <galak@codeaurora.org>, netdev@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467327554-22074-6-git-send-email-jon.mason@broadcom.com>
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

[snip]

+
> +	return 0;
> +
> +err2:
> +	devm_iounmap(&pdev->dev, bgmac->plat.idm_base);
> +err1:
> +	devm_iounmap(&pdev->dev, bgmac->plat.base);
> +err:
> +	devm_kfree(&pdev->dev, bgmac);


This is not needed actually, now that you use the device managed helper
functions.

> +
> +	return rc;
> +}
> +
> +static int bgmac_remove(struct platform_device *pdev)
> +{
> +	struct bgmac *bgmac = platform_get_drvdata(pdev);
> +
> +	bgmac_enet_remove(bgmac);
> +	devm_iounmap(&pdev->dev, bgmac->plat.idm_base);
> +	devm_iounmap(&pdev->dev, bgmac->plat.base);
> +	devm_kfree(&pdev->dev, bgmac);

Same here.
-- 
Florian

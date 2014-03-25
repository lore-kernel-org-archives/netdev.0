From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V13 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Tue, 25 Mar 2014 08:05:44 +0100
Message-ID: <20140325070543.GA26998@electric-eye.fr.zoreil.com>
References: <00a001cf46d8$f4c38bd0$de4aa370$@samsung.com>
 <20140324234505.GA22059@electric-eye.fr.zoreil.com>
 <015b01cf47d7$8a8e5c40$9fab14c0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, "'David Miller'" <davem@davemloft.net>,
	"'GIRISH K S'" <ks.giri@samsung.com>,
	"'SIVAREDDY KALLAM'" <siva.kallam@samsung.com>,
	"'Vipul Chandrakant'" <vipul.pandya@samsung.com>,
	"'Ilho Lee'" <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <015b01cf47d7$8a8e5c40$9fab14c0$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Byungho An <bh74.an@samsung.com> :
[...]
> How about below ?

The for loops should be unrolled.

(style: no need to join before branching)

I must go to work, so you'll have to fill the dots in the code below:

        priv = sxgbe_drv_probe(&(pdev->dev), plat_dat, addr);
        if (!priv) {
                pr_err("%s: main driver probe failed\n", __func__);
                goto err_something;
        }

        /* Get the SXGBE common INT information */
        priv->irq  = irq_of_parse_and_map(node, 0);
        if (priv->irq <= 0) {
                dev_err(dev, "sxgbe common irq parsing failed\n");
                goto err_drv_remove;
        }

        /* Get the TX/RX IRQ numbers */
        for (i = 0, chan = 1; i < SXGBE_TX_QUEUES; i++) {
                priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
                if (priv->txq[i]->irq_no <= 0) {
                        dev_err(dev, "sxgbe tx irq parsing failed\n");
                        goto err_tx_irq_unmap;
                }
        }

        for (i = 0; i < SXGBE_RX_QUEUES; i++) {
                priv->rxq[i]->irq_no = irq_of_parse_and_map(node, chan++);
                if (priv->rxq[i]->irq_no <= 0) {
                        dev_err(dev, "sxgbe rx irq parsing failed\n");
                        goto err_rx_irq_unmap;
                }
        }

        platform_set_drvdata(pdev, priv->dev);

        pr_debug("platform driver registration completed\n");

        return 0;

err_rx_irq_unmap:
	/* TODO: check that 'i' isn't unsigned. */
	while (i--)
		irq_dispose_mapping(priv->rx[i]->irq_no);
	i = SXGBE_TX_QUEUES;
err_tx_irq_unmap:
	while (i--)
		irq_dispose_mapping(priv->tx[i]->irq_no);
	irq_dispose_mapping(priv->irq);
err_drv_remove:
        sxgbe_drv_remove(ndev);
err_something:
	...

-- 
Ueimor

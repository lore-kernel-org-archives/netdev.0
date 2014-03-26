From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v6] can: xilinx CAN controller support
Date: Tue, 25 Mar 2014 22:39:17 -0700
Message-ID: <1395812357.3726.14.camel@joe-AO722>
References: <5ff46a21-3047-40ff-9221-f08e476f9ce6@VA3EHSMHS030.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, mkl@pengutronix.de, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5ff46a21-3047-40ff-9221-f08e476f9ce6@VA3EHSMHS030.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-26 at 10:56 +0530, Kedareswara rao Appana wrote:
> This patch adds xilinx CAN controller support.
> This driver supports both ZYNQ CANPS and Soft IP
> AXI CAN controller.

Just trivial notes about dmesg logging output.

> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
[]
> +static int set_reset_mode(struct net_device *ndev)
> +{
[]
> +			netdev_warn(ndev, "timedout waiting for config mode\n");

timed out

> +static int xcan_set_bittiming(struct net_device *ndev)
> +{
[]
> +	if (!is_config_mode) {
> +		netdev_alert(ndev,
> +			"BUG! Cannot set bittiming can is notin config mode\n");

"Cannot set bit timing - CAN is not in config mode\n"

> +static int xcan_chip_start(struct net_device *ndev)
> +{

> +			netdev_warn(ndev,
> +				"time out waiting for correct mode\n");

Please be consistent.  Maybe
"timed out waiting for correct mode\n"

> +static int xcan_open(struct net_device *ndev)
> +{
> +	struct xcan_priv *priv = netdev_priv(ndev);
> +	int ret;
> +
> +	ret = request_irq(ndev->irq, xcan_interrupt, priv->irq_flags,
> +			ndev->name, ndev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "Irq allocation for CAN failed\n");

irq is almost always lower case.



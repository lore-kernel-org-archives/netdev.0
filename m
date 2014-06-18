From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH net-next v2 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Wed, 18 Jun 2014 10:10:10 +0100
Message-ID: <20140618091010.GB26461@leverpostej>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in>
 <1403068565-32224-2-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1403068565-32224-2-git-send-email-varkab@cdac.in>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2014 at 06:16:03AM +0100, Varka Bhadram wrote:
> Driver support:
>         - Tx and Rx of IEEE-802.15.4 packets.
>         - Energy Detection on channel.
>         - Setting the Channel for the radio. [b/w 11 - 26 channels]
>         - Start and Stop the radio.
>
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ieee802154/cc2520.c |  968 +++++++++++++++++++++++++++++++++++++++
>  include/linux/spi/cc2520.h      |   26 ++
>  2 files changed, 994 insertions(+)
>  create mode 100644 drivers/net/ieee802154/cc2520.c
>  create mode 100644 include/linux/spi/cc2520.h

[...]

> +static struct cc2520_platform_data *
> +cc2520_get_platform_data(struct spi_device *spi)
> +{
> +       struct cc2520_platform_data *pdata;
> +       struct device_node __maybe_unused *np = spi->dev.of_node;
> +       struct cc2520_private *priv = spi_get_drvdata(spi);
> +
> +       if (!IS_ENABLED(CONFIG_OF) || !np)
> +               return spi->dev.platform_data;

Surely "if (!np)" is good enough?

[...]

> +static int cc2520_probe(struct spi_device *spi)
> +{
> +       struct cc2520_private *priv;
> +       struct pinctrl *pinctrl;
> +       struct cc2520_platform_data *pdata;
> +       struct device_node __maybe_unused *np = spi->dev.of_node;

This looks to be definitely unused rather than __maybe_unused. There are
no other occuences of "np" in this function.

Mark.

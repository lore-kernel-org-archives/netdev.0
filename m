From: Joe Perches <joe@perches.com>
Subject: Re: ping [PATCH v3] WAN: Adding support for Lantiq PEF2256 E1
 chipset (FALC56)
Date: Sun, 19 Jan 2014 11:34:55 -0800
Message-ID: <1390160095.2290.9.camel@joe-AO722>
References: <20140119180732.A1D99432AF@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Grant Likely <grant.likely@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, marc.balemboy@c-s.fr
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0125.hostedemail.com ([216.40.44.125]:45557 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751727AbaASTfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 14:35:01 -0500
In-Reply-To: <20140119180732.A1D99432AF@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-19 at 19:07 +0100, Christophe Leroy wrote:
> Pinging this watch as we got no feedback since 22 Nov, although we have taken
> into account reviews from v1 and v2.
> 
> The patch adds WAN support for Lantiq FALC56 - PEF2256 E1 Chipset.

trivia:

> diff -urN a/drivers/net/wan/pef2256.c b/drivers/net/wan/pef2256.c
[]
> +static void config_hdlc_timeslot(struct pef2256_dev_priv *priv, int ts)
> +{
> +	static struct {
> +		u32 ttr;
> +		u32 rtr;
> +	} regs[] = {
> +		{ TTR1, RTR1 },
> +		{ TTR2, RTR2 },
> +		{ TTR3, RTR3 },
> +		{ TTR4, RTR4 },
> +	};

const

> +	int cfg_bit = 1 << (31 - ts);
> +	int reg_bit = 1 << (7 - (ts % 8));
> +	int j = ts / 8;

looks endian specific

> +
> +	if (j >= 4)
> +		return;
> +
> +	if (priv->Tx_TS & cfg_bit)
> +		pef2256_s8(priv, regs[j].ttr, 1 << reg_bit);
> +
> +	if (priv->Rx_TS & cfg_bit)
> +		pef2256_s8(priv, regs[j].rtr, 1 << reg_bit);
> +}

> +static void init_falc(struct pef2256_dev_priv *priv)
> +{

a lot of the below looks like it should use
switch/case blocks.

> +	/* Clocking rate for FALC56 */
> +
> +	/* Nothing to do for clocking rate 2M  */
> +
> +	/* clocking rate 4M  */
> +	if (priv->clock_rate == CLOCK_RATE_4M)
> +		pef2256_s8(priv, SIC1, SIC1_SSC0);
> +
> +	/* clocking rate 8M  */
> +	if (priv->clock_rate == CLOCK_RATE_8M)
> +		pef2256_s8(priv, SIC1, SIC1_SSC1);
> +
> +	/* clocking rate 16M  */
> +	if (priv->clock_rate == CLOCK_RATE_16M) {
> +		pef2256_s8(priv, SIC1, SIC1_SSC0);
> +		pef2256_s8(priv, SIC1, SIC1_SSC1);
> +	}
> +
> +	/* data rate for FALC56 */
> +
> +	/* Nothing to do for data rate 2M on the system data bus */
> +
> +	/* data rate 4M on the system data bus */
> +	if (priv->data_rate == DATA_RATE_4M)
> +		pef2256_s8(priv, FMR1, FMR1_SSD0);
> +
> +	/* data rate 8M on the system data bus */
> +	if (priv->data_rate == DATA_RATE_8M)
> +		pef2256_s8(priv, SIC1, SIC1_SSD1);
> +
> +	/* data rate 16M on the system data bus */
> +	if (priv->data_rate == DATA_RATE_16M) {
> +		pef2256_s8(priv, FMR1, FMR1_SSD0);
> +		pef2256_s8(priv, SIC1, SIC1_SSD1);
> +	}
> +
> +	/* channel phase for FALC56 */
> +
> +	/* Nothing to do for channel phase 1 */
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_2)
> +		pef2256_s8(priv, SIC2, SIC2_SICS0);
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_3)
> +		pef2256_s8(priv, SIC2, SIC2_SICS1);
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_4) {
> +		pef2256_s8(priv, SIC2, SIC2_SICS0);
> +		pef2256_s8(priv, SIC2, SIC2_SICS1);
> +	}
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_5)
> +		pef2256_s8(priv, SIC2, SIC2_SICS2);
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_6) {
> +		pef2256_s8(priv, SIC2, SIC2_SICS0);
> +		pef2256_s8(priv, SIC2, SIC2_SICS2);
> +	}
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_7) {
> +		pef2256_s8(priv, SIC2, SIC2_SICS1);
> +		pef2256_s8(priv, SIC2, SIC2_SICS2);
> +	}
> +
> +	if (priv->channel_phase == CHANNEL_PHASE_8) {
> +		pef2256_s8(priv, SIC2, SIC2_SICS0);
> +		pef2256_s8(priv, SIC2, SIC2_SICS1);
> +		pef2256_s8(priv, SIC2, SIC2_SICS2);
> +	}

> +static ssize_t fs_attr_mode_store(struct device *dev,
> +			struct device_attribute *attr,  const char *buf,
> +			size_t count)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +	long int value;
> +	int ret = kstrtol(buf, 10, &value);
> +	int reconfigure = (value != priv->mode);

Ugly test and set before determining if the previous
function was successful.

> +	if (value != MASTER_MODE && value != SLAVE_MODE)
> +		ret = -EINVAL;
> +
> +	if (ret < 0)
> +		netdev_info(ndev, "Invalid mode (0 or 1 expected\n");
> +	else {
> +		priv->mode = value;
> +		if (reconfigure && netif_carrier_ok(ndev))
> +			init_falc(priv);
> +	}
> +
> +	return strnlen(buf, count);

odd that you set ret and then don't use it.


> +static ssize_t fs_attr_Tx_TS_store(struct device *dev,
> +			struct device_attribute *attr,  const char *buf,
> +			size_t count)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +	unsigned long value;
> +	int ret = kstrtoul(buf, 16, (long int *)&value);

unportable cast

> +	int reconfigure = (value != priv->mode);

again with the test/set before determining function success.

From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH RFC V2 2/2] net: qualcomm: new Ethernet over SPI driver
 for QCA7000
Date: Thu, 3 Jul 2014 11:49:40 +0200
Message-ID: <20140703094939.GB27655@distanz.ch>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
 <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, eric.dumazet@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:59297 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030185AbaGCJtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2014 05:49:43 -0400
Content-Disposition: inline
In-Reply-To: <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-07-01 at 18:36:49 +0200, Stefan Wahren <stefan.wahren@i2se.com> wrote:
> This patch adds the Ethernet over SPI driver for the
> Qualcomm QCA7000 HomePlug GreenPHY.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/qualcomm/Kconfig       |   30 +
>  drivers/net/ethernet/qualcomm/Makefile      |    6 +
>  drivers/net/ethernet/qualcomm/qca_7k.c      |  149 ++++
>  drivers/net/ethernet/qualcomm/qca_7k.h      |   72 ++
>  drivers/net/ethernet/qualcomm/qca_debug.c   |  311 +++++++++
>  drivers/net/ethernet/qualcomm/qca_debug.h   |   34 +
>  drivers/net/ethernet/qualcomm/qca_framing.c |  155 +++++
>  drivers/net/ethernet/qualcomm/qca_framing.h |  134 ++++
>  drivers/net/ethernet/qualcomm/qca_spi.c     | 1001 +++++++++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/qca_spi.h     |  114 +++
>  12 files changed, 2008 insertions(+)
>  create mode 100644 drivers/net/ethernet/qualcomm/Kconfig
>  create mode 100644 drivers/net/ethernet/qualcomm/Makefile
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.h
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.h
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.h

[...]

> +static int
> +qcaspi_netdev_set_mac_address(struct net_device *dev, void *addr)
> +{
> +	struct sockaddr *sa = addr;
> +
> +	if (netif_running(dev))
> +		return -EBUSY;
> +
> +	if (!is_valid_ether_addr(sa->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
> +	return 0;
> +}
> +
> +static const struct net_device_ops qcaspi_netdev_ops = {
> +	.ndo_init = qcaspi_netdev_init,
> +	.ndo_uninit = qcaspi_netdev_uninit,
> +	.ndo_open = qcaspi_netdev_open,
> +	.ndo_stop = qcaspi_netdev_close,
> +	.ndo_start_xmit = qcaspi_netdev_xmit,
> +	.ndo_change_mtu = qcaspi_netdev_change_mtu,
> +	.ndo_set_mac_address = qcaspi_netdev_set_mac_address,

You can use eth_mac_addr here which does the same thing as your
implementation.

> +	.ndo_tx_timeout = qcaspi_netdev_tx_timeout,
> +	.ndo_validate_addr = eth_validate_addr,
> +};

From: Colin Ian King <colin.king@canonical.com>
Subject: re: amd-xgbe: Add support for MDIO attached PHYs
Date: Tue, 15 Nov 2016 13:07:10 +0000
Message-ID: <6e653058-6442-5bcf-7e02-3136780caffb@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35448 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933653AbcKONHU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 08:07:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Commit:

amd-xgbe: Add support for MDIO attached PHYs

    Use the phylib support in the kernel to communicate with and control an
    MDIO attached PHY. Use the hardware's MDIO communication mechanism to
    communicate with the PHY.


+static int xgbe_clr_gpio(struct xgbe_prv_data *pdata, unsigned int gpio)
+{
+       unsigned int reg;
+
+       if (gpio > 16)
+               return -EINVAL;

is gpio in the range 0..15?

	if (gpio > 15)
		return -EINVAL;

+
+       reg = XGMAC_IOREAD(pdata, MAC_GPIOSR);
+
+       reg &= ~(1 << (gpio + 16));

if gpio is 16, we get 1 << 32 which I believe is undefined behaviour.

+       XGMAC_IOWRITE(pdata, MAC_GPIOSR, reg);
+
+       return 0;
+}


Same applies for function xgbe_clr_gpio().

Colin

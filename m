From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed, 5 Aug 2015 16:16:10 -0700
Message-ID: <20150805161610.3bcdde98@urahara>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
	<20150805094057.59260077@urahara>
	<20150805171652.GG20890@e106497-lin.cambridge.arm.com>
	<20150805203342.GA26748@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Liviu Dudau <Liviu.Dudau@arm.com>,
	Mirko Lindner <mlindner@marvell.com>,
	"ryan.harkin@linaro.org" <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805203342.GA26748@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Something like this:

Subject: [PATCH net-next] sky2: use random address if EEPROM is bad

On some embedded systems the EEPROM does not contain a valid MAC address.
In that case it is better to fallback to a generated mac address and
let init scripts fix the value later.

Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/marvell/sky2.c	2015-05-21 15:13:03.621126050 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2015-08-05 16:12:38.734534467 -0700
@@ -4819,6 +4819,16 @@ static struct net_device *sky2_init_netd
 		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
 			      ETH_ALEN);
 
+	/* if the address is invalid, use a random value */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		struct sockaddr sa = { AF_UNSPEC };
+
+		netdev_warn(dev,
+			 "Invalid MAC address defaulting to random\n");
+		sky2_set_mac_address(dev, &sa);
+		dev->addr_assign_type |= NET_ADDR_RANDOM;
+	}
+
 	return dev;
 }
 

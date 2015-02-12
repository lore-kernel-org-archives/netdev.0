From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next v2 0/3] Adjust the settings about USB_RX_EARLY_AGG
Date: Thu, 12 Feb 2015 14:33:45 +0800
Message-ID: <1394712342-15778-141-Taiwan-albertk@realtek.com>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-137-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

v2:
For patch #1, replace

	u32 ocp_data;
	ocp_data = tp->coalesce / 8;

with

	u32 ocp_data = tp->coalesce / 8;

And replace

	struct net_device *dev = tp->netdev;
	u32 ocp_data;
	ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;

with

	u32 mtu = tp->netdev->mtu;
	u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;

Use *switch* statement to replace the checking of *if*.

v1:
The USB_RX_EARLY_AGG contains timeout and size. Separate them, and
they could be set independently. Then, the ethtool could be used to
change the timeout according to situation of the platform.

Hayes Wang (3):
  r8152: separate USB_RX_EARLY_AGG
  r8152: change rx early size when the mtu is changed
  r8152: support setting rx coalesce

 drivers/net/usb/r8152.c | 128 ++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 101 insertions(+), 27 deletions(-)

-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

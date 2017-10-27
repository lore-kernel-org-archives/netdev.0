From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: get rid of false alarm "Unknown cmd 27"
 in dmesg
Date: Fri, 27 Oct 2017 14:37:03 -0700
Message-ID: <20171027213703.GA1107@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0066.outbound.protection.outlook.com ([104.47.37.66]:43194
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751515AbdJ0VhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 17:37:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating a macvtap interface with the liquidio VF driver as lower device
causes this alarming message to show up in dmesg:

    liquidio_link_ctrl_cmd_completion Unknown cmd 27

That's actually a false alarm because cmd 27 is the value of the macro
OCTNET_CMD_SET_UC_LIST which is known.  It's a control command sent from
host to NIC firmware to set the unicast MAC address list of the macvtap
lower device.

Make the false alarm go away by adding a case for OCTNET_CMD_SET_UC_LIST
in liquidio_link_ctrl_cmd_completion().

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index b891d85..89b7820 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -143,6 +143,7 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 	switch (nctrl->ncmd.s.cmd) {
 	case OCTNET_CMD_CHANGE_DEVFLAGS:
 	case OCTNET_CMD_SET_MULTI_LIST:
+	case OCTNET_CMD_SET_UC_LIST:
 		break;
 
 	case OCTNET_CMD_CHANGE_MACADDR:

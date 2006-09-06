From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Wed, 6 Sep 2006 09:41:17 -0700
Message-ID: <Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>
 <44FEE679.6030201@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22201 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1751651AbWIFQlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 12:41:18 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44FEE679.6030201@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add 10 Gig support to bonding.

Resent due to corrupt patch.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>

diff -urpN -X linux-2.6.18-rc4-clean/Documentation/dontdiff linux-2.6.18-rc4-clean/drivers/net/bonding/bond_3ad.c linux-2.6.18-rc4/drivers/net/bonding/bond_3ad.c
--- linux-2.6.18-rc4-clean/drivers/net/bonding/bond_3ad.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.18-rc4/drivers/net/bonding/bond_3ad.c	2006-08-30 11:31:45.000000000 -0700
@@ -85,6 +85,7 @@
 #define     AD_LINK_SPEED_BITMASK_10MBPS      0x2
 #define     AD_LINK_SPEED_BITMASK_100MBPS     0x4
 #define     AD_LINK_SPEED_BITMASK_1000MBPS    0x8
+#define     AD_LINK_SPEED_BITMASK_10000MBPS   0x10
 //endalloun

 // compare MAC addresses
@@ -330,7 +331,8 @@ static inline void __release_rx_machine_
  *     0,
  *     %AD_LINK_SPEED_BITMASK_10MBPS,
  *     %AD_LINK_SPEED_BITMASK_100MBPS,
- *     %AD_LINK_SPEED_BITMASK_1000MBPS
+ *     %AD_LINK_SPEED_BITMASK_1000MBPS,
+ *     %AD_LINK_SPEED_BITMASK_10000MBPS
  */
 static u16 __get_link_speed(struct port *port)
 {
@@ -357,6 +359,10 @@ static u16 __get_link_speed(struct port
 			speed = AD_LINK_SPEED_BITMASK_1000MBPS;
 			break;

+		case SPEED_10000:
+			speed = AD_LINK_SPEED_BITMASK_10000MBPS;
+			break;
+
 		default:
 			speed = 0; // unknown speed value from ethtool. shouldn't happen
 			break;
@@ -775,6 +781,9 @@ static u32 __get_agg_bandwidth(struct ag
 		case AD_LINK_SPEED_BITMASK_1000MBPS:
 			bandwidth = aggregator->num_of_ports * 1000;
 			break;
+		case AD_LINK_SPEED_BITMASK_10000MBPS:
+			bandwidth = aggregator->num_of_ports * 10000;
+			break;
 		default:
 			bandwidth=0; // to silent the compilor ....
 		}
diff -urpN -X linux-2.6.18-rc4-clean/Documentation/dontdiff linux-2.6.18-rc4-clean/drivers/net/bonding/bond_main.c linux-2.6.18-rc4/drivers/net/bonding/bond_main.c
--- linux-2.6.18-rc4-clean/drivers/net/bonding/bond_main.c	2006-08-21 13:28:43.000000000 -0700
+++ linux-2.6.18-rc4/drivers/net/bonding/bond_main.c	2006-08-30 10:49:37.000000000 -0700
@@ -638,6 +638,7 @@ verify:
 	case SPEED_10:
 	case SPEED_100:
 	case SPEED_1000:
+	case SPEED_10000:
 		break;
 	default:
 		return -1;

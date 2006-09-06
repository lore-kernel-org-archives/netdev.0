From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Wed, 06 Sep 2006 12:22:29 -0700
Message-ID: <200609061922.k86JMTZt027278@death.nxdomain.ibm.com>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com> <44FEE679.6030201@pobox.com> <Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:17033 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751524AbWIFTWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 15:22:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k86JMXci011805
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:22:36 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k86JMYNJ291446
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:22:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k86JMXim010767
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 15:22:34 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
In-reply-to: <Pine.CYG.4.58.0609060939150.3076@mawilli1-desk2.amr.corp.intel.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	[Trying again; /usr/bin/patch didn't complain about Mitch's
original; here's a cg-diff generated from where I checked his in,
git-apply seems ok with it.  The problem seems to be the empty line
between "//endallnoun" and "// compare MAC"; in the original it's a
totally empty line, from cg-diff, there's a single space on there. -J]

Add 10 Gig support to bonding.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6a40707..c24b20a 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -85,6 +85,7 @@ #define     AD_LINK_SPEED_BITMASK_1MBPS 
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
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8b95123..110da94 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -638,6 +638,7 @@ verify:
 	case SPEED_10:
 	case SPEED_100:
 	case SPEED_1000:
+	case SPEED_10000:
 		break;
 	default:
 		return -1;

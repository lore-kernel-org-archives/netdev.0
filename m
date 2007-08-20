From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V4 0/10] net/bonding: ADD IPoIB support for the bonding driver
Date: Mon, 20 Aug 2007 18:34:12 +0300
Message-ID: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com, davem@davemloft.net, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:25480 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758872AbXHTPeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 11:34:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is the fourth version (see below link to V3) of the 
suggested changes to the bonding driver so it would be able to support 
non ARPHRD_ETHER netdevices for its High-Availability (active-backup) mode. 

The motivation is to enable the bonding driver on its HA mode to work with 
the IP over Infiniband (IPoIB) driver. With these patches I was able to enslave 
IPoIB netdevices and run TCP, UDP, IP (UDP) Multicast and ICMP traffic with 
fail-over and fail-back working fine. The working environment was the net-2.6 git. 

More over, as IPoIB is also the IB ARP provider for the RDMA CM driver which 
is used by native IB ULPs whose addressing scheme is based on IP (e.g. iSER, 
SDP, Lustre, NFSoRDMA, RDS), bonding support for IPoIB devices **enables** HA 
for these ULPs. This holds as when the ULP is informed by the IB HW on the 
failure of the current IB connection, it just need to reconnect, where the 
bonding device will now issue the IB ARP over the active IPoIB slave. 

This series also includes patches to the IPoIB driver that fix some fix 
some neighboring related issues. 

Major changes from the previous version:

1) Addressing the issue of safety when unloading the IPoIB module before
the bonding module
2) style changes


Links to earlier discussion: 

1. A discussion in netdev about bonding support for IPoIB.
http://lists.openwall.net/netdev/2006/11/30/46

2. A discussion in openfabrics regarding changes in the IPoIB that 
enable using it as a slave for bonding.
http://lists.openfabrics.org/pipermail/general/2007-July/038914.html


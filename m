From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [ofa-general] [PATCH 00/11] IPoIB support for bonding
Date: Fri, 14 Sep 2007 16:40:19 -0700
Message-ID: <11898132301664-git-send-email-fubar@us.ibm.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>, general@lists.openfabrics.org,
	jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

	Following is patch set to provide IPoIB support for bonding in
active-backup mode.  Patches 1 - 10 were originally posted by Moni Shoua
<monis@voltaire.com>.  The changes look reasonable to me, but others (for
IB and net/core changes) probably need to ack.

	Patch 11 modifies the IB "don't copy MAC to all slaves" code in
bonding to also be optional for ethernet devices; this is occasionally
useful.

Original preface for patches 1 - 10 from Moni Shoua <monis@voltaire.com>:

This patch series is the fourth version (see below link to V3) of the 
suggested changes to the bonding driver so it would be able to support 
non ARPHRD_ETHER netdevices for its High-Availability (active-backup) mode. 

The motivation is to enable the bonding driver on its HA mode to work with
the IP over Infiniband (IPoIB) driver. With these patches I was able to
enslave IPoIB netdevices and run TCP, UDP, IP (UDP) Multicast and ICMP
traffic with fail-over and fail-back working fine. The working environment
was the net-2.6 git.

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

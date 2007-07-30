From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V3 0/7] net/bonding: ADD IPoIB support for the
	bonding driver
Date: Mon, 30 Jul 2007 15:37:29 +0300
Message-ID: <46ADDB89.5030601@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com,  davem@davemloft.net,  fubar@us.ibm.com
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

This patch series is the third version (see below link to V2) of the 
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

There are still 2 open issues here: 
1. When bonding enslaves an IPoIB device the bonding neighbor holds a 
reference to a cleanup function in the IPoIB drives. This makes it unsafe to 
unload the IPoIB module if there are bonding neighbors in the air. So, to 
avoid this race one must unload bonding before unloading IPoIB. 

2. Patch No. 7 is a workaround to a problem where gratuitous were not sent quite often.
I didn't find something better that fixes this and I would 
appreciate advices and comments regarding it. However, this doesn't seem to me as 
an issue related exclusively to IPoIB. 

Links to earlier discussion: 

1. A discussion in netdev about bonding support for IPoIB.
http://lists.openwall.net/netdev/2006/11/30/46

2. A discussion in openfabrics regarding changes in the IPoIB that 
enable using it as a slave for bonding.
http://lists.openfabrics.org/pipermail/general/2007-March/034033.html

From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] add GENEVE netdev tunnel driver
Date: Fri,  8 May 2015 13:20:52 -0400
Message-ID: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49266 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbbEHRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 13:22:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This 5-patch kernel series adds a netdev implementation of a GENEVE
tunnel driver, and the single iproute2 patch enables creation and
such for those netdevs.  This makes use of the existing GENEVE
infrastructure already used by the OVS code.  The net/ipv4/geneve.c
file is renamed as net/ipv4/geneve_core.c as part of these changes.

 drivers/net/Kconfig            |   14 +
 drivers/net/Makefile           |    1 
 drivers/net/geneve.c           |  550 +++++++++++++++++++++++++++++++++++++++++
 include/net/geneve.h           |    5 
 include/uapi/linux/if_link.h   |    9 
 net/ipv4/Kconfig               |    4 
 net/ipv4/Makefile              |    2 
 net/ipv4/geneve.c              |    6 
 net/ipv4/geneve_core.c         |    4 
 net/openvswitch/Kconfig        |    2 
 net/openvswitch/vport-geneve.c |    5 
 11 files changed, 585 insertions(+), 17 deletions(-)

The overall structure of the GENEVE netdev driver is strongly
influenced by the VXLAN netdev driver.  This is not surprising, as the
two drivers are intended to serve similar purposes.  As development of
the GENEVE driver continues, it is likely that those similarities will
grow stronger.  This will include both simple configuration options
(e.g. TOS and TTL settings) and new control plane support.

The current implementation is very simple, restricting itself to point
to point links over IPv4.  This is due only to the simplicity of the
implementation, and no such limit is inherent to GENEVE in any way.
Support for IPv6 links and more sophisticated control plane options
are predictable enhancements.

Using the included iproute2 patch, a GENEVE tunnel is created thusly:

        ip link add dev gnv0 type geneve remote 192.168.22.1 vni 1234
        ip link set gnv0 up
        ip addr add 10.1.1.1/24 dev gnv0

After a corresponding tunnel interface is created at the link partner,
traffic should proceed as expected.

Please let me know if anyone has problems...thanks!

John
--
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

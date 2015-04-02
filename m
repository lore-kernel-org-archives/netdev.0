From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC] add GENEVE netdev tunnel driver
Date: Thu,  2 Apr 2015 15:17:01 -0400
Message-ID: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49874 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbbDBTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 15:19:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This 5-patch kernel series adds a netdev implementation of a GENEVE
tunnel driver, and the single iproute2 patch enables creation and
such for those netdevs.  This makes use of the existing GENEVE
infrastructure already used by the OVS code.  The net/ipv4/geneve.c
file is renamed as net/ipv4/libgeneve.c as part of these changes.

The overall structure of the GENEVE netdev driver is strongly
influenced by the VXLAN netdev driver.  This is not surprising, as the
two drivers are intended to serve similar purposes.  As development
of the GENEVE driver continues, it is likely that those similarities
will grow stronger.

The current implementation is very simple, restricting itself to a
single GENEVE tunnel netdev per net namespace.  This is due only to
the simplicity of the implementation, and no such limit is inherent
to GENEVE in any way.  I am releasing this as an RFC patch series at
this point both as a means of reporting progress on this effort and
in hopes of collecting useful feedback.

Using the included iproute2 patch, a GENEVE tunnel is created thusly:

	ip link add dev gnv0 type geneve remote 192.168.22.1 vni 1234
	ip link set gnv0 up
	ip addr add 10.1.1.1/24 dev gnv0

After a corresponding tunnel interface is created at the link partner,
traffic should proceed as expected.

Please let me know if anyone has problems.  I look forward to your
feedback!

John

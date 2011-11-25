From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 0/4] AX.25 and NET/ROM fixes and improvments.
Date: Fri, 25 Nov 2011 09:55:50 +0000
Message-ID: <cover.1322214950.git.ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>, Joerg Reuter <jreuter@yaina.de>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Walter Harms <wharms@bfs.de>,
	Thomas Osterried <thomas@osterried.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:52587 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754595Ab1KYLJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 06:09:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AX.25 ioctl didn't do sufficient argument checking.  The result of these
overflows is harmless as it will be dealt with further further down in the
stack but an application should get an error code when trying to set
such a bogus value.  To not restrict the more extreme use cases of AX.25
there is no attempt to clamp values to a "sensible" range.

The NET/ROM stack's routing ioctl didn't check the lengths of the mnemonic
string that is being passed as part of the nr_route_struct structure to the
kernel.  In theory this could result in an oops but no memory corruption
but again is fairly harmless because it requires CAP_NET_ADMIN priviledges
which in practice only root has and ax25-tools don't send malformed 
ioctls.

Two further patches simplify the checks at the beginning of nr_rt_ioctl
and do minor reformatting to nr_ioctl.

Patches 1 and 2 are meant for v3.2; 3 and 4 are only cosmetic and thus
are v3.3 material.

Ralf Baechle (4):
  NET: AX.25: Check ioctl arguments to avoid overflows further down the
    road.
  NET: NETROM: When adding a route verify length of mnemonic string.
  NET: NETROM: Cleanup argument SIOCADDRT ioctl argument checking.
  NET: NETROM: Fix formatting.

 net/ax25/af_ax25.c     |   17 +++++++++++------
 net/netrom/af_netrom.c |    3 ++-
 net/netrom/nr_route.c  |   11 +++++++----
 3 files changed, 20 insertions(+), 11 deletions(-)

-- 
1.7.4.4

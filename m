From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] flowi6_tos fixes
Date: Fri, 18 Mar 2016 18:37:56 +0100
Message-ID: <cover.1458320940.git.daniel@iogearbox.net>
Cc: jbenc@redhat.com, linville@tuxdriver.com, jesse@kernel.org,
	dsa@cumulusnetworks.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53378 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556AbcCRRiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 13:38:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set is a follow-up to address Jiri's recent feedback [1] on
the flowi6_tos issue, that it is not used for IPv6 route lookups.
The three patches fix all current users of flowi6_tos and remove
the define to avoid any future confusion on this. Tested the vxlan
and geneve ones with IPv6 routing rules. For details, please see
individual patches.

[ As fixes are currently applied against net-next tree, I've rebased
  it against that. ]

Thanks!

  [1] http://patchwork.ozlabs.org/patch/592055/

Daniel Borkmann (3):
  vxlan: fix populating tclass in vxlan6_get_route
  geneve: fix populating tclass in geneve_get_v6_dst
  ipv6, trace: fix tos reporting on fib6_table_lookup

 drivers/net/geneve.c        | 11 ++++++-----
 drivers/net/vxlan.c         |  3 +--
 include/net/flow.h          |  2 +-
 include/net/ipv6.h          |  6 ++++++
 include/trace/events/fib6.h |  2 +-
 5 files changed, 15 insertions(+), 9 deletions(-)

-- 
1.9.3

From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 0/4] vxlan: implement Generic Protocol Extension (GPE)
Date: Tue,  5 Apr 2016 14:47:09 +0200
Message-ID: <cover.1459860270.git.jbenc@redhat.com>
Cc: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56021 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbcDEMr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 08:47:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3: just rebased on top of the current net-next, no changes

This patchset implements VXLAN-GPE. It follows the same model as the tun/tap
driver: depending on the chosen mode, the vxlan interface is created either
as ARPHRD_ETHER (non-GPE) or ARPHRD_NONE (GPE).

Note that the internal fdb control plane cannot be used together with
VXLAN-GPE and attempt to configure it will be rejected by the driver. In
fact, COLLECT_METADATA is required to be set for now. This can be relaxed in
the future by adding support for static PtP configuration; it will be
backward compatible and won't affect existing users.

The previous version of the patchset supported two GPE modes, L2 and L3. The
L2 mode (now called "ether mode" in the code) was removed from this version.
It can be easily added later if there's demand. The L3 mode is now called
"raw mode" and supports also encapsulated Ethernet headers (via ETH_P_TEB).

The only limitation of not having "ether mode" for GPE is for ip route based
encapsulation: with such setup, only IP packets can be encapsulated. Meaning
no Ethernet encapsulation. It seems there's not much use for this, though.
If it turns out to be useful, we'll add it.

Jiri Benc (4):
  vxlan: move Ethernet initialization to a separate function
  vxlan: move fdb code to common location in vxlan_xmit
  ip_tunnel: implement __iptunnel_pull_header
  vxlan: implement GPE

 drivers/net/vxlan.c          | 210 ++++++++++++++++++++++++++++++++++++-------
 include/net/ip_tunnels.h     |  11 ++-
 include/net/vxlan.h          |  68 ++++++++++++++
 include/uapi/linux/if_link.h |   1 +
 net/ipv4/ip_tunnel_core.c    |   8 +-
 5 files changed, 258 insertions(+), 40 deletions(-)

-- 
1.8.3.1

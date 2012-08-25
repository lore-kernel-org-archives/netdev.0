From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 0/3] forcedeth: fix device lock-up for dual-port NICs
Date: Fri, 24 Aug 2012 20:22:50 -0700
Message-ID: <cover.1345864542.git.decot@googlers.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: Ayaz Abdulla <aabdulla@nvidia.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:35387 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185Ab2HYDXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 23:23:08 -0400
Received: by eekd4 with SMTP id d4so120353eek.1
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 20:23:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a dual port MCP55 10de:0373 (rev a3) NIC with both ports connected,
we identified a configuration that does freeze the whole NIC: having
autoneg & TX pause turned on while one port is physically connected
but interface is down (eg. eth1) eventually causes the whole NIC to
freeze (eth1 and... eth0). This triggers TX timeouts on the UP
interface and, more generally, an unreachable network.

In order to avoid the bug, all we have to do is make sure not to
configure TX pause on the hardware while NIC is down. This is what the
2nd patch of the series does (details included).

And, in case the NIC is in a bad state at reboot (should not happen
anymore thanks to patch above), third patch basically always makes
sure to fix the NIC when module is loaded.

I could only test this with a MCP55 10de:0373 (rev a3) PCI device on a
x86_64 host.

Any feedback on these patches welcome! In particular, please let me
know if this should not apply to other hardware.


############################################
# Patch Set Summary:

David Decotigny (3):
  forcedeth: fix buffer overflow
  forcedeth: fix TX timeout caused by TX pause on down link
  forcedeth: prevent TX timeouts after reboot

 drivers/net/ethernet/nvidia/forcedeth.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

-- 
1.7.10.2.5.g20d7bc9

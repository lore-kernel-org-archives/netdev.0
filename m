From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 0/2] macvtap: Add support for offload control
Date: Wed, 19 Jun 2013 10:47:50 -0400
Message-ID: <1371653272-11703-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, mst@redhat.com, jasowang@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731Ab3FSOsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 10:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently macvtap does not allow control of offload functionality via
TUNSETOFFLOAD ioctl.  However, this is the ioctl that qemu uses when
attempting to control offload functionality.  This patch series adds
the ability to control offloads via the ioctl above.

It also adds necessary code to macvtap to perform segmentation upon
forwarding the packets to tap.  This is needed if offloads on the
macvtap interface are disabled, but lower-level device still performs
GRO.

Vlad Yasevich (2):
  macvtap: Let TUNSETOFFLOAD actually controll offload features.
  macvtap: Perform GSO on forwarding path.

 drivers/net/macvlan.c      |  9 +++++++
 drivers/net/macvtap.c      | 67 ++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/if_macvlan.h |  1 +
 3 files changed, 75 insertions(+), 2 deletions(-)

-- 
1.8.1.4

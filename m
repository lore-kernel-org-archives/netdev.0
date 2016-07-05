From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCHv2 0/2] Netns performance improvements
Date: Tue,  5 Jul 2016 16:51:18 +0200
Message-ID: <1467730280-17493-1-git-send-email-phil@nwl.cc>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33225 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933141AbcGEOvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 10:51:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stress-testing OpenStack Neutron revealed poor performance of 'ip netns'
when dealing with a high amount of namespaces. The cause of this lies in
the combination of how iproute2 mounts NETNS_RUN_DIR and the netns files
therein and the fact that systemd makes all mount points of the system
shared.

Changes since v1:
- Added Suggested-by tag to patches.

Phil Sutter (2):
  ipnetns: Move NETNS_RUN_DIR into it's own propagation group
  ipnetns: Make netns mount points private

 ip/ipnetns.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

-- 
2.8.2

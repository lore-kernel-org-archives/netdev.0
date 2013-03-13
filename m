From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 0/4]  Allow bridge to function in non-promisc mode
Date: Tue, 12 Mar 2013 21:45:22 -0400
Message-ID: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755412Ab3CMBpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 21:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series adds an ability for the bridge to function in non-promiscuous mode.
We do it in 3 steps.
First we add an interface to palce the switch into non-promisc mode.  In
this mode, all port of the switch turn promisc off and turn on IFF_ALLMULTI
to continue handling multicast traffic.
Second we add an ability to designate a bridge port as uplink.
Third we add IFF_UNICAST_FLT support to the bridge and sync all unicast
HW addresses to the uplink ports.

Default bridge operation continues to remain "promiscuous".  The new
functionality has to be enabled via sysfs (similar to other bridge extensions).

The uplink mode is implemented as a flag on a bridge port.  The api to
change that flag follows the existing api to enable/disable other existing
flags.

Changes since rfc v2:
* Sync/unsync address on uplink upon the uplink flag change.  This allows
for uplink replacements without loss of addresses.

Changes since rfc v1:
* Fixed submit log
* Simplifyied uplink logic.  Uplink is now a flag per port.  This removes the
  need for a separate list.
* Clean-up hw list once the port has been removed.

Vlad Yasevich (4):
  bridge: Add sysfs interface to control promisc mode
  bridge: Allow an ability to designate an uplink port
  bridge: Implement IFF_UNICAST_FLT
  bridge: sync device list when a new uplink is designated

 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_device.c       |   52 +++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_fdb.c          |    6 +++++
 net/bridge/br_if.c           |   24 +++++++++++++++----
 net/bridge/br_netlink.c      |   13 ++++++++++
 net/bridge/br_private.h      |    3 ++
 net/bridge/br_sysfs_br.c     |   17 +++++++++++++
 net/bridge/br_sysfs_if.c     |   27 +++++++++++++++++++++
 8 files changed, 137 insertions(+), 6 deletions(-)

-- 
1.7.7.6

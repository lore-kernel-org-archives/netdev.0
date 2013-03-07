From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH v2 net-next 0/3] Allow bridge to function in
	non-promisc mode
Date: Thu,  7 Mar 2013 16:28:45 -0500
Message-ID: <1362691728-13289-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The series adds an ability to configure the bridge into a non-primiscuous
mode.   Instead, it provides the ability to identitfy some set of bridge
ports as uplinks and allows for MAC addresses to be programmed onto
those ports.  In case the port hardware does not support mac filter,
that port will be placed in promiscuous mode.

Default bridge operation continues to remain as "promiscuous".  The new
functionality has to be enabled via sysfs (similar to other bridge extensions).

The uplink mode is implemented as a flag on a bridge port.  The api to
change that flag follows the existing api to enable/disable other existing
flags.

All comments are welcome.

Changes since v1:
* Fixed submit log
* Simplifyied uplink logic.  Uplink is now a flag per port.  This removes the
  need for a separate list.
* Clean-up hw list once the port has been removed.

Vlad Yasevich (3):
  bridge: Add sysfs interface to control promisc mode
  bridge: Allow an ability to designate an uplink port
  bridge: Implement IFF_UNICAST_FLT

 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_device.c       |   52 +++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_fdb.c          |    6 +++++
 net/bridge/br_if.c           |   22 +++++++++++++----
 net/bridge/br_netlink.c      |    2 +
 net/bridge/br_private.h      |    3 ++
 net/bridge/br_sysfs_br.c     |   17 +++++++++++++
 net/bridge/br_sysfs_if.c     |    2 +
 8 files changed, 99 insertions(+), 6 deletions(-)

-- 
1.7.7.6

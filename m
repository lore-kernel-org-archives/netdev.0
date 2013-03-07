From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH net-next 0/3] Allow bridge to function in
	non-promisc mode
Date: Wed,  6 Mar 2013 21:31:22 -0500
Message-ID: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
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

This is a first stab at the series that allows bridge to function
in non-promiscuouse mode.

The series adds a sysfs control to turn off promiscusouse mode all on ports of
the bridge.  To handle multicast, we turn on IFF_ALLMULTI for now.  Eventually
we would deal with multicast addresses.

The second patch adds an ability to designate an uplink port on the bridge.

Finally, we add an ability to add hw address to the bridge and sync those
addresses to the uplink ports.

In this way a bridge could be programmed with appropriate mac addresses and
could function in non-promiscuouse mode.

All comments are welcome.

Vlad Yasevich (3):
  bridge: Add mac_management sysfs interface
  bridge: Allow an ability to designate an uplink port
  bridge: Implement IFF_UNICAST_FLT

 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_device.c       |   51 +++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_fdb.c          |    6 +++++
 net/bridge/br_if.c           |   38 +++++++++++++++++++++++++++----
 net/bridge/br_netlink.c      |    6 +++++
 net/bridge/br_private.h      |    6 +++++
 net/bridge/br_sysfs_br.c     |   17 ++++++++++++++
 net/bridge/br_sysfs_if.c     |   13 ++++++++++
 8 files changed, 132 insertions(+), 6 deletions(-)

-- 
1.7.7.6

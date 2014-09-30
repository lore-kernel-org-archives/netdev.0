From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net 0/3] bridge: Add vlan filtering support for
	default pvid
Date: Tue, 30 Sep 2014 15:30:59 -0400
Message-ID: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Vladislav Yasevich <vyasevic@redhat.com>
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

Version 2 of the series to introduce the default pvid support to
vlan filtering in the bridge.  VLAN 1 (as recommended by 802.1q spec)
is used as default pvid on ports. 
The the user can over-ride this configuration by configuring their
own vlan information. 
The user can additionally change the default value throught the
sysfs interface (netlink comming shortly).
The user can turn off default pvid functionality by setting default
pvid to 0. 
This series changes the default behavior of the bridge when
vlan filtering is turned on.  Currently, ports without any vlan
filtering configured will not recevie any traffic at all.  This patch
changes the behavior of the above ports to receive only untagged traffic.

Since v2:
- Add ability to turn off default_pvid settings.
- Drop the automiatic filtering support based on configured vlan devices (will
  be its own series)

Thanks
-vlad


Vladislav Yasevich (3):
  bridge: Add a default_pvid sysfs attribute
  bridge: Simplify pvid checks.
  bridge: Add filtering support for default_pvid

 net/bridge/br_device.c   |   8 ++-
 net/bridge/br_if.c       |   2 +
 net/bridge/br_private.h  |  17 +++++-
 net/bridge/br_sysfs_br.c |  17 ++++++
 net/bridge/br_vlan.c     | 143 ++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 179 insertions(+), 8 deletions(-)

-- 
1.9.3

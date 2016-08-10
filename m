From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 0/3] Make /proc per net namespace objects belong to container
Date: Wed, 10 Aug 2016 14:35:59 -0700
Message-ID: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently [almost] all /proc objects belong to the global root, even if
data belongs to a given namespace within a container and (at least for
sysctls) we work around permssions checks to allow container's root to
access the data.

This series changes ownership of net namespace /proc objects
(/proc/net/self/* and /proc/sys/net/*) to be container's root and not
global root when there exists mapping for container's root in user
namespace.

This helps when running Android CTS in a container, but I think it makes
sense regardless.

Changes from V1:

- added fix for crash when !CONFIG_NET_NS (new patch #1)
- addressed Eric'c comments for error handling style in patch #3 and
  added his Ack
- adjusted patch #2 to use the same style of erro handling
- sent out as series instead of separate patches

Dmitry Torokhov (3):
  netns: do not call pernet ops for not yet set up init_net namespace
  proc: make proc entries inherit ownership from parent
  net: make net namespace sysctls belong to container's owner

 fs/proc/generic.c        |  2 ++
 fs/proc/proc_net.c       | 13 +++++++++++++
 fs/proc/proc_sysctl.c    |  5 +++++
 include/linux/sysctl.h   |  4 ++++
 net/core/net_namespace.c | 21 +++++++++++++++++----
 net/sysctl_net.c         | 29 ++++++++++++++++++++---------
 6 files changed, 61 insertions(+), 13 deletions(-)

-- 
2.8.0.rc3.226.g39d4020

From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH v2 0/3] Fix some multiqueue TUN problems
Date: Wed, 05 Dec 2012 15:25:56 -0500
Message-ID: <20121205202144.18626.61966.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Second draft of the LSM/SELinux fixes to the upcoming multiqueue TUN
functionality.  This draft incorporates all the comments/decisions
from the first draft, notably the new LSM and SELinux hook for the
TUNSETQUEUE operation.  Other LSMs do not provide TUN controls so they
are not affected.

Once we decide this is the right approach I'll push the associated
SELinux policy FLASK definitions upstream; for those who are interested
the SELinux policy diff in included in the description of patch 1/2.

I don't expect this to be the final patch, just a starting point for
further discussion so I didn't really do any testing, simply making
sure that it compiled cleanly.

---

Paul Moore (3):
      tun: correctly report an error in tun_flow_init()
      selinux: add the "create_queue" permission to the "tun_socket" class
      tun: fix LSM/SELinux labeling of tun/tap devices


 drivers/net/tun.c                   |   29 +++++++++++++----
 include/linux/security.h            |   59 +++++++++++++++++++++++++++--------
 security/capability.c               |   24 ++++++++++++--
 security/security.c                 |   28 ++++++++++++++---
 security/selinux/hooks.c            |   50 +++++++++++++++++++++++-------
 security/selinux/include/classmap.h |    2 +
 security/selinux/include/objsec.h   |    4 ++
 7 files changed, 156 insertions(+), 40 deletions(-)

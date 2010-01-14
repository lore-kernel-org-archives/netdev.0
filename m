From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 0/3] vbus: venet macvlan rt netlink changes
Date: Thu, 14 Jan 2010 16:52:55 -0500
Message-ID: <20100114215058.4958.87746.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Applies to alacrityvm.git/master:a725f9950)

This series changes the venet macvlan device such that it can
be created via rt netlink and no longer requires any extensive
changes to the macvlan device itself. The first patch removes
prior changes to the macvlan device introduced in the alacrityvm
tree and also implements the changes needed for creation and
management via rt netlink. The subsequent patches(2 and 3) are
changes to the macvlan device for GRO support and for type
specific release. These 2 patches don't appear to be upstream.
If desired and approved, I'll regenerate these last 2 for
net-next.

---

Patrick Mullaney (3):
      macvlan: use rtnl_link_ops->dellink during unregister notications
      macvlan: add GRO bit to features mask
      venet-macvlan: allow rt netlink to create venet macvlan devices


 drivers/net/macvlan.c                   |   72 ++----
 include/linux/macvlan.h                 |    6 -
 kernel/vbus/devices/venet/device.c      |    8 +
 kernel/vbus/devices/venet/macvlan.c     |  360 ++++++++++++++++++++-----------
 kernel/vbus/devices/venet/tap.c         |    3 
 kernel/vbus/devices/venet/venetdevice.h |    3 
 6 files changed, 265 insertions(+), 187 deletions(-)

-- 

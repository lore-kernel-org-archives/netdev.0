From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 02 Jun 2009 02:48:58 -0700 (PDT)
Message-ID: <20090602.024858.24420647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753133AbZFBJs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:48:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The e1000 length check patch is pretty important and allows to
easily OOPS the e1000 driver.

The forcedeth PHY powerdown change fixes a particularly pugnant
problem folks have been running into.  Because BIOS's, other OS's
and even older versions of Linux don't explicitly power-up the
PHY on driver load, powering it down at shutdown makes the device
inoperable until the next power cycle.  So default to not doing
this, the user can enable it with a module option.

The packet classifier API can crash if the configuration of a new rule
fails, it won't even destroy it.  We have to be careful to not put
the new rule into the list until the configuration method passes.

Bluetooth does flush_work()'s which are 1) unnecessary and 2)
introduce deadlocks.

Please pull, thanks a lot!

The following changes since commit d9244b5d2fbfe9fa540024b410047af13ceec90f:
  Linus Torvalds (1):
        Merge branch 'hwmon-for-linus' of git://git.kernel.org/.../jdelvare/staging

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Dave Young (1):
      Bluetooth: Remove useless flush_work() causing lockdep warnings

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Ed Swierk (1):
      forcedeth: add phy_power_down parameter, leave phy powered up by default (v2)

Minoru Usui (1):
      net_cls: fix unconfigured struct tcf_proto keeps chaining and avoid kernel panic when we use cls_cgroup

Neil Horman (1):
      e1000: add missing length check to e1000 receive routine

 drivers/net/e1000/e1000_main.c |    5 +++--
 drivers/net/forcedeth.c        |   15 +++++++++++++--
 net/bluetooth/hci_sysfs.c      |    6 ------
 net/sched/cls_api.c            |   23 +++++++++++++++++------
 4 files changed, 33 insertions(+), 16 deletions(-)

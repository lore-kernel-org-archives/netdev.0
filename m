From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Wed, 12 Jul 2006 23:49:55 +0200
Message-ID: <1152740995.14173.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:32710 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1751442AbWGLVtp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 17:49:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are some bug fixes for the Bluetooth subsystem. I included the
kzalloc cleanup since I saw you still taking these kind of updates.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_ldisc.c |    4 ++--
 net/bluetooth/cmtp/capi.c     |    4 +---
 net/bluetooth/cmtp/core.c     |    3 +--
 net/bluetooth/hci_core.c      |    7 ++-----
 net/bluetooth/hidp/Kconfig    |    3 +--
 net/bluetooth/hidp/core.c     |    3 +--
 net/bluetooth/l2cap.c         |   18 +++++++++---------
 net/bluetooth/rfcomm/core.c   |    9 +++++----
 net/bluetooth/rfcomm/tty.c    |    3 +--
 net/bluetooth/sco.c           |   12 +++++-------
 10 files changed, 28 insertions(+), 38 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Wed, 12 Jul 2006 23:00:07 +0200

    [Bluetooth] Fix deadlock in the L2CAP layer

    The Bluetooth L2CAP layer has 2 locks that are used in softirq context,
    (one spinlock and one rwlock, where the softirq usage is readlock) but
    where not all usages of the lock were _bh safe. The patch below corrects
    this.

    Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Wed, 12 Jul 2006 22:57:52 +0200

    [Bluetooth] Let BT_HIDP depend on INPUT

    This patch lets BT_HIDP depend on instead of select INPUT. This fixes
    the following warning during an s390 build:

    net/bluetooth/hidp/Kconfig:4:warning: 'select' used by config symbol
    'BT_HIDP' refer to undefined symbol 'INPUT'

    A dependency on INPUT also implies !S390 (and therefore makes the
    explicit dependency obsolete) since INPUT is not available on s390.

    The practical difference should be nearly zero, since INPUT is always
    set to y unless EMBEDDED=y (or S390=y).

    Signed-off-by: Adrian Bunk <bunk@stusta.de>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 15:53:31 +0200

    [Bluetooth] Avoid NULL pointer dereference with tty->driver

    This patch checks for tty->driver before trying to call flush_buffer().

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 15:40:09 +0200

    [Bluetooth] Remaining transitions to use kzalloc()

    This patch makes the remaining transitions to use kzalloc().

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




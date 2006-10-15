From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Sun, 15 Oct 2006 18:10:24 +0200
Message-ID: <1160928624.14340.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:63899 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1751102AbWJOQKl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 12:10:41 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are my pending bugfixes for the 2.6.19 kernel. They should resolve
various Bugzilla reports and other issues reported over the last couple
of weeks. Please forward them to Linus as soon as possible.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/bcm203x.c      |   17 +++-----
 include/net/bluetooth/hci_core.h |   17 ++++++++
 net/bluetooth/af_bluetooth.c     |   38 ++++++++++++++----
 net/bluetooth/bnep/core.c        |    4 -
 net/bluetooth/bnep/sock.c        |   69 ++++++++++++++++++++++++---------
 net/bluetooth/cmtp/sock.c        |   35 ++++++++++++++++-
 net/bluetooth/hci_conn.c         |    6 +-
 net/bluetooth/hci_event.c        |   15 +++++--
 net/bluetooth/hci_sock.c         |    2 
 net/bluetooth/hci_sysfs.c        |   17 ++++----
 net/bluetooth/hidp/core.c        |    8 +--
 net/bluetooth/hidp/sock.c        |   80 ++++++++++++++++++++++++++++++++++++++-
 net/bluetooth/l2cap.c            |    5 +-
 net/bluetooth/rfcomm/core.c      |    3 -
 net/bluetooth/rfcomm/sock.c      |    6 +-
 net/bluetooth/rfcomm/tty.c       |    7 +--
 net/bluetooth/sco.c              |    6 +-
 17 files changed, 264 insertions(+), 71 deletions(-)

through these ChangeSets:

Commit: a712c36b91da9a514b6a0422dc9dcc5bb7ade305 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:31:19 +0200 

    [Bluetooth] Use work queue to trigger URB submission
    
    The bcm203x firmware loading driver uses a timer to trigger the URB
    submission. It is better to use a work queue instead.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: ecf49920b7a4dbd5186a52ea1755f9cd41636e56 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:31:14 +0200 

    [Bluetooth] Add locking for bt_proto array manipulation
    
    The bt_proto array needs to be protected by some kind of locking to
    prevent a race condition between bt_sock_create and bt_sock_register.
    
    And in addition all calls to sk_alloc need to be made GFP_ATOMIC now.
    
    Signed-off-by: Masatake YAMATO <jet@gyve.org>
    Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: f988274ac38b5257eddac8b9d04d471f21691897 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:31:10 +0200 

    [Bluetooth] Check if DLC is still attached to the TTY
    
    If the DLC device is no longer attached to the TTY device, then it
    makes no sense to go through with changing the termios settings.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: fff5558a9c5a03ea5c04eaaac78cf2ca98cce018 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:31:05 +0200 

    [Bluetooth] Fix reference count when connection lookup fails
    
    When the connection lookup for the device structure fails, the reference
    count for the HCI device needs to be decremented.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: a3b3a59dba17ccb9effaa1eb2773e1efbb6ece89 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:31:00 +0200 

    [Bluetooth] Disconnect HID interrupt channel first
    
    The Bluetooth HID specification demands that the interrupt channel
    shall be disconnected first. This is needed to pass the qualification
    tests.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 49f0ce71de260c6cebf232b7e6865453af9a5056 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:30:56 +0200 

    [Bluetooth] Support concurrent connect requests
    
    Most Bluetooth chips don't support concurrent connect requests, because
    this would involve a multiple baseband page with only one radio. In the
    case an upper layer like L2CAP requests a concurrent connect these chips
    return the error "Command Disallowed" for the second request. If this
    happens it the responsibility of the Bluetooth core to queue the request
    and try again after the previous connect attempt has been completed.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 8100163b3e5c7d3d248d51b5bcb009c35ea9db63 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:30:50 +0200 

    [Bluetooth] Make use of virtual devices tree
    
    The Bluetooth subsystem currently uses a platform device for devices
    with no parent. It is a better idea to use the new virtual devices
    tree for these.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: c9f320a15ef6d6d31e4063c118ed097266f6be13 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:30:45 +0200 

    [Bluetooth] Handle return values from driver core functions
    
    Some return values of the driver core register and create functions
    are not handled and so might cause unexpected problems.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 3def4bc6d9f77d4c66298b094ff3723b2a2d23e5 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 15 Oct 2006 17:30:22 +0200 

    [Bluetooth] Fix compat ioctl for BNEP, CMTP and HIDP
    
    There exists no attempt do deal with the fact that a structure with
    a uint32_t followed by a pointer is going to be different for 32-bit
    and 64-bit userspace. Any 32-bit process trying to use it will be
    failing with -EFAULT if it's lucky; suffering from having data dumped
    at a random address if it's not.
    
    Signed-off-by: David Woodhouse <dwmw2@infradead.org>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




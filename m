From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2009-02-27
Date: Fri, 27 Feb 2009 06:35:29 +0100
Message-ID: <1235712929.27004.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53855 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751AbZB0Ffq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 00:35:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are the Bluetooth patches for the 2.6.30 kernel release. All of
them have been in bluetooth-testing.git for a while. We tested them
heavily at the last UnPlugFest and also against the qualification test
system.

The majority of these patches improve the Simple Pairing support and
ensures that we have the best interoperability while enforcing the best
possible security protection.

The problems with SCO/eSCO establishment should now all be fixed. Some
Bluetooth chips are just too stupid to do the right thing.

The Android guys found a few race conditions with the L2CAP connection
setup and they should also be fixed now.

The Bluetooth USB driver now submits its bulk URBs together with the
interrupt URBs. This is a stupid requirement, but some Bluetooth chips
didn't like the missing bulk URBs at all.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/bfusb.c         |    3 +-
 drivers/bluetooth/bt3c_cs.c       |    4 +-
 drivers/bluetooth/btusb.c         |   40 ++-
 drivers/bluetooth/hci_h4.c        |    3 +-
 drivers/bluetooth/hci_ll.c        |    3 +-
 include/net/bluetooth/bluetooth.h |   12 +
 include/net/bluetooth/hci.h       |    8 +
 include/net/bluetooth/hci_core.h  |   84 ++++--
 include/net/bluetooth/l2cap.h     |   13 +-
 include/net/bluetooth/rfcomm.h    |   20 +-
 net/bluetooth/af_bluetooth.c      |   17 +-
 net/bluetooth/cmtp/core.c         |    3 +-
 net/bluetooth/hci_conn.c          |   64 +++--
 net/bluetooth/hci_core.c          |    3 +-
 net/bluetooth/hci_event.c         |   26 ++-
 net/bluetooth/l2cap.c             |  602 +++++++++++++++++++++++++++----------
 net/bluetooth/rfcomm/core.c       |  179 ++++++-----
 net/bluetooth/rfcomm/sock.c       |  189 +++++++++++-
 net/bluetooth/sco.c               |   57 +++-
 19 files changed, 968 insertions(+), 362 deletions(-)

through these ChangeSets:

Andre Haupt (1):
    Bluetooth: Eliminate a sparse warning in bt3c driver

Dave Young (2):
    Bluetooth: Remove CONFIG_DEBUG_LOCK_ALLOC ifdefs
    Bluetooth: Move hci_conn_del_sysfs() back to avoid device destruct

Jaikumar Ganesh (1):
    Bluetooth: When encryption is dropped, do not send RFCOMM packets

Marcel Holtmann (31):
    Bluetooth: Preparation for usage of SOL_BLUETOOTH
    Bluetooth: Add global deferred socket parameter
    Bluetooth: Add support for deferring RFCOMM connection setup
    Bluetooth: Add support for deferring L2CAP connection setup
    Bluetooth: Reject incoming SCO connections without listeners
    Bluetooth: Fix SCO state handling for incoming connections
    Bluetooth: Add enhanced security model for Simple Pairing
    Bluetooth: Replace L2CAP link mode with security level
    Bluetooth: Replace RFCOMM link mode with security level
    Bluetooth: Pause RFCOMM TX when encryption drops
    Bluetooth: Disconnect L2CAP connections without encryption
    Bluetooth: Restrict application of socket options
    Bluetooth: Update version numbers
    Bluetooth: Submit bulk URBs along with interrupt URBs
    Bluetooth: Don't check encryption for L2CAP raw sockets
    Bluetooth: Add SCO fallback for eSCO connection attempts
    Bluetooth: Use general bonding whenever possible
    Bluetooth: Set authentication requirements if not available
    Bluetooth: Fix race condition with L2CAP information request
    Bluetooth: Fix double L2CAP connection request
    Bluetooth: Don't enforce authentication for L2CAP PSM 1 and 3
    Bluetooth: Request L2CAP fixed channel list if available
    Bluetooth: Add CID field to L2CAP socket address structure
    Bluetooth: Ask upper layers for HCI disconnect reason
    Bluetooth: Fix authentication requirements for L2CAP security check
    Bluetooth: Set authentication requirement before requesting it
    Bluetooth: Fix poll() misbehavior when using BT_DEFER_SETUP
    Bluetooth: Change RFCOMM to use BT_CONNECT2 for BT_DEFER_SETUP
    Bluetooth: Disallow usage of L2CAP CID setting for now
    Bluetooth: Fix RFCOMM usage of in-kernel L2CAP sockets
    Bluetooth: Permit BT_SECURITY also for L2CAP raw sockets

Victor Shcherbatyuk (1):
    Bluetooth: Fix issue with return value of rfcomm_sock_sendmsg()

Wei Yongjun (2):
    Bluetooth: Remove some pointless conditionals before kfree_skb()
    Bluetooth: Remove some pointless conditionals before kfree_skb()




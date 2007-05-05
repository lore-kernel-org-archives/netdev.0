From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.22
Date: Sat, 05 May 2007 03:23:38 +0200
Message-ID: <1178328218.2891.3.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:36271 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767935AbXEEBXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 21:23:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

these are the Bluetooth fixes for the 2.6.22 kernel release. Please pull
and send them of to Linus as soon as possible since one of them actually
fixes an information leak.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c |    6 ++++++
 net/bluetooth/hci_sock.c    |    9 +++++++++
 net/bluetooth/hci_sysfs.c   |    9 ++++++++-
 net/bluetooth/l2cap.c       |    6 ++++++
 net/bluetooth/rfcomm/core.c |   29 ++++++++++++++++-------------
 net/bluetooth/rfcomm/tty.c  |   11 ++++++++---
 6 files changed, 53 insertions(+), 17 deletions(-)

through these ChangeSets:

Commit: 7bb078cba9ef55d810275b533747fa96a12e1823 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:36:22 +0200 

    [Bluetooth] Correct SCO buffer for another Broadcom based dongle
    
    The SCO buffer size values for Bluetooth chips from Broadcom are wrong
    and the USB Bluetooth driver has to set a quirk to correct these SCO
    buffer size values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: c51bd3d3d883d900efbeab3697ae182d60bdd217 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:36:17 +0200 

    [Bluetooth] Add support for Targus ACB10US USB dongle
    
    This patch adds the vendor and product id of the Targus ACB10US
    dongle and sets a flag to send HCI_Reset as the first command.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org

Commit: 9cf5b0ea3a7f1432c61029f7aaf4b8b338628884 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:36:13 +0200 

    [Bluetooth] Disconnect L2CAP connection after last RFCOMM DLC
    
    The RFCOMM specification says that the device closing the last DLC on
    a particular session is responsible for closing the multiplexer by
    closing the corresponding L2CAP channel.
    
    Signed-off-by: Ville Tervo <ville.tervo@nokia.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 77f2a45fa1ba33147fd6cc8ae546188504a822cd 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:36:10 +0200 

    [Bluetooth] Check that device is in rfcomm_dev_list before deleting
    
    If RFCOMM_RELEASE_ONHUP flag is on and rfcomm_release_dev is called
    before connection is closed, rfcomm_dev is deleted twice from the
    rfcomm_dev_list and refcount is messed up. This patch adds a check
    before deleting device that the device actually is listed.
    
    Signed-off-by: Ville Tervo <ville.tervo@nokia.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 48db9ca4f2ac9f39eb90ccb12ad3ca7b645a552c 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:36:06 +0200 

    [Bluetooth] Use in-kernel sockets API
    
    The kernel provides a new convenient way to access the sockets API for
    in-kernel users. It is a good idea to actually use it.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 53c1d4b0b22243c093ded25aaa01c8ff8ab6e6b3 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:36:03 +0200 

    [Bluetooth] Attach host adapters to the Bluetooth bus
    
    The Bluetooth host adapters are attached to the Bluetooth class and the
    low-level connections are children of these class devices. Having class
    devices as parent of bus devices breaks a lot of reasonable assumptions
    about sysfs. The host adapters should be attached to the Bluetooth bus
    to simplify the dependency resolving. For compatibility an additional
    symlink from the Bluetooth class will be used.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 0878b6667f28772aa7d6b735abff53efc7bf6d91 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 05 May 2007 00:35:59 +0200 

    [Bluetooth] Fix L2CAP and HCI setsockopt() information leaks
    
    The L2CAP and HCI setsockopt() implementations have a small information
    leak that makes it possible to leak kernel stack memory to userspace.
    
    If the optlen parameter is 0, no data will be copied by copy_from_user(),
    but the uninitialized stack buffer will be read and stored later. A call
    to getsockopt() can now retrieve the leaked information.
    
    To fix this problem the stack buffer given to copy_from_user() must be
    initialized with the current settings.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




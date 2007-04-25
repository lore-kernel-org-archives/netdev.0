From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.21-rc7
Date: Thu, 26 Apr 2007 01:05:55 +0200
Message-ID: <1177542355.14980.46.camel@aeonflux.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@suse.de>, Kay Sievers <kay.sievers@vrfy.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:49730 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993135AbXDYXan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:30:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I have two last minute patches before the final 2.6.21 kernel hits the
streets. One is a kernel memory leak that has been classified as
security issue. The second one is a sysfs fix to correct a wrong use of
class and bus devices.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 net/bluetooth/hci_sock.c  |    9 +++++++++
 net/bluetooth/hci_sysfs.c |    9 ++++++++-
 net/bluetooth/l2cap.c     |    6 ++++++
 3 files changed, 23 insertions(+), 1 deletion(-)

through these ChangeSets:

Commit: 9457de6253a222a8c340b0442fb63c172069d962 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 25 Apr 2007 22:38:39 +0200 

    [Bluetooth] Attach host adapters to the Bluetooth bus
    
    The Bluetooth host adapters are attached to the Bluetooth class and the
    low-level connections are children of these class devices. Having class
    devices as parent of bus devices breaks a lot of reasonable assumptions
    about sysfs. The host adapters should be attached to the Bluetooth bus
    to simplify the dependency resolving. For compatibility an additional
    symlink from the Bluetooth class will be used.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 32f1cf0a4643018f8473065d645dbc6b5772e93c 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 25 Apr 2007 22:38:34 +0200 

    [Bluetooth] Fix L2CAP and HCI setsockopt() information leaks
    
    The L2CAP and HCI setsockopt() implementations have a small information
    leak that makes it possible to leak kernel stack memory to userspace.
    
    If the optlen parameter is 0, no data will be copied by copy_from_user(),
    but the uninitialized stack buffer will be read and stored later. A call
    to getsockopt() can now retrieve the leaked information.
    
    To fix this problem the stack buffer given to copy_from_user() must be
    initialized with the current settings.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.20
Date: Sun, 18 Feb 2007 00:10:52 +0100
Message-ID: <1171753852.9069.10.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:37921 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992841AbXBQXPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 18:15:17 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are some patches for the Bluetooth subsystem. All of them are
pending patches that can be finally included since the missing core
functionality has been merged upstream.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/bcm203x.c |    2 
 drivers/bluetooth/bfusb.c   |    1 
 drivers/bluetooth/bt3c_cs.c |    1 
 net/bluetooth/hidp/Kconfig  |    1 
 net/bluetooth/hidp/core.c   |  182 +++++++++++++++++++++++++++++++++++++++++---
 net/bluetooth/hidp/hidp.h   |    2 
 net/bluetooth/hidp/sock.c   |    2 
 net/bluetooth/rfcomm/tty.c  |    9 +-
 8 files changed, 189 insertions(+), 11 deletions(-)

through these ChangeSets:

Commit: 8999556264a621f819bbd14c71d824cf43fa37a7 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 17 Feb 2007 23:59:02 +0100 

    [Bluetooth] Make use of MODULE_FIRMWARE
    
    Some Bluetooth drivers need one or more binary firmware images. Export
    these image names via the MODULE_FIRMWARE tag.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 5fc3d1d1dc61c098c2b92149bd120b1f18d7444c 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 17 Feb 2007 23:58:57 +0100 

    [Bluetooth] Make use of device_move() for RFCOMM TTY devices
    
    In the case of bound RFCOMM TTY devices the parent is not available
    before its usage. So when opening a RFCOMM TTY device, move it to
    the corresponding ACL device as a child. When closing the device,
    move it back to the virtual device tree.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: a26f55306461d8258a6ea602c416907748e313cd 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 17 Feb 2007 23:58:53 +0100 

    [Bluetooth] Add open and close callbacks for HID device
    
    The open and close callbacks for the HID device are not optional, but
    for the Bluetooth HID report mode support it is enough to add empty
    dummy callbacks.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: af5350062ebac7d7645309f7a0ecbef87ffec89e 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 17 Feb 2007 23:58:49 +0100 

    [Bluetooth] Add support for using the HID subsystem
    
    This patch extends the current Bluetooth HID support to use the new
    HID subsystem and adds full report mode support.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: a3f95f9bae0cfe810faadb315850aead8e121aec 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 17 Feb 2007 23:58:44 +0100 

    [Bluetooth] Fix wrong put_user() from HIDP compat ioctl patch
    
    The compat ioctl patch copied the parser version field into the
    report descriptor size field by mistake.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth fixes for 2.6.20-rc4
Date: Mon, 08 Jan 2007 01:31:44 +0100
Message-ID: <1168216304.12025.10.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:40842 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbXAHAxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jan 2007 19:53:54 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are the missing fixes for the Bluetooth subsystem that should go in
before the final 2.6.20 release. Please forward them to Linus as soon as
possible.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c |    7 +++++++
 net/bluetooth/cmtp/capi.c   |   39 +++++++++++++++++++++++++++++++++------
 net/bluetooth/hci_sysfs.c   |    7 ++++++-
 net/bluetooth/rfcomm/sock.c |    5 +++--
 net/bluetooth/rfcomm/tty.c  |   22 +++++++++++++++-------
 5 files changed, 64 insertions(+), 16 deletions(-)

through these ChangeSets:

Commit: e2fe5c641a149ec0a136f6c40b582a36acd48e29 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:57 +0100 

    [Bluetooth] Correct SCO buffer for Broadcom based Dell laptops
    
    The SCO buffer size values on Dell laptops with a Bluetooth chip from
    Broadcom are wrong. The USB Bluetooth driver has to set a quirk to
    correct the SCO buffer size values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: ad84b8efd5c82d3081e13718b82141afba59cae6 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:50 +0100 

    [Bluetooth] Correct SCO buffer for Broadcom based HP laptops
    
    The SCO buffer size values on HP laptops with a Bluetooth chip from
    Broadcom are wrong. The USB Bluetooth driver has to set a quirk to
    correct the SCO buffer size values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: b4dc4e184068a7462cb8e5934152f3dece27bd33 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:47 +0100 

    [Bluetooth] Correct SCO buffer size for another ThinkPad laptop
    
    The ThinkPad R60E uses a Broadcom based Bluetooth chip and even this
    version needs the quirk to correct the SCO buffer size values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 0772e9f351bc5dc5ee0c55302b4aa943fca33705 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:41 +0100 

    [Bluetooth] Handle device registration failures
    
    In the case the device registration for a new Bluetooth low-level
    connection fails there is no need to unregister it when the temporary
    data structure has been removed.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 2b2e64be763c5e64d4ae4a061825b18decf1edf7 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:33 +0100 

    [Bluetooth] Fix uninitialized return value for RFCOMM sendmsg()
    
    When calling send() with a zero length parameter on a RFCOMM socket
    it returns a positive value. In this rare case the variable err is
    used uninitialized and unfortunately its value is returned.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 9d1e13e54d56999804d5d025d236900056ebe7bf 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 01:00:22 +0100 

    [Bluetooth] More checks if DLC is still attached to the TTY
    
    If the DLC device is no longer attached to the TTY device, then return
    errors or default values for various callbacks of the TTY layer.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 7c778531f600749801de1cbca297c94083c5f217 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 08 Jan 2007 00:59:58 +0100 

    [Bluetooth] Add packet size checks for CAPI messages
    
    With malformed packets it might be possible to overwrite internal
    CMTP and CAPI data structures. This patch adds additional length
    checks to prevent these kinds of remote attacks.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




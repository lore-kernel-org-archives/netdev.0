From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.24
Date: Sat, 20 Oct 2007 16:00:16 +0200
Message-ID: <1192888816.6184.117.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:58507 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbXJTOHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2007 10:07:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

these are the Bluetooth patches for the 2.6.24 kernel release. Please
pull and send them to Linus.

I assigned the next free constant for SOL_BLUETOOTH which will be used
to consolidate all the new socket options that are work in progress.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/Kconfig        |   35 
 drivers/bluetooth/Makefile       |    4 
 drivers/bluetooth/bluecard_cs.c  |    5 
 drivers/bluetooth/bpa10x.c       |  624 ++++++--------
 drivers/bluetooth/bt3c_cs.c      |    5 
 drivers/bluetooth/btsdio.c       |  406 +++++++++
 drivers/bluetooth/btuart_cs.c    |    5 
 drivers/bluetooth/btusb.c        |  564 +++++++++++++
 drivers/bluetooth/dtl1_cs.c      |    5 
 drivers/bluetooth/hci_bcsp.c     |    3 
 drivers/bluetooth/hci_ldisc.c    |    8 
 drivers/bluetooth/hci_ll.c       |  531 ++++++++++++
 drivers/bluetooth/hci_uart.h     |    8 
 include/linux/socket.h           |    1 
 include/net/bluetooth/hci.h      |  604 ++++++++------
 include/net/bluetooth/hci_core.h |   13 
 include/net/bluetooth/l2cap.h    |   37 
 net/bluetooth/hci_conn.c         |   82 +
 net/bluetooth/hci_core.c         |   70 +
 net/bluetooth/hci_event.c        | 1651 +++++++++++++++++++++------------------
 net/bluetooth/hci_sock.c         |    2 
 net/bluetooth/hci_sysfs.c        |   37 
 net/bluetooth/hidp/core.c        |    2 
 net/bluetooth/l2cap.c            |  306 ++++---
 net/bluetooth/rfcomm/tty.c       |   25 
 net/bluetooth/sco.c              |   12 
 26 files changed, 3524 insertions(+), 1521 deletions(-)

through these ChangeSets:

Commit: 4c5534cce0c2be513ee071b41536d91180a775e2 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 15:28:08 +0200 

    [Bluetooth] Add constant for Bluetooth socket options level
    
    Assign the next free socket options level to be used by the Bluetooth
    protocol and address family.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: c0c9360deb699f4647b901611af73d2935f4d16a 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 14:55:10 +0200 

    [Bluetooth] Add support for handling simple eSCO links
    
    With the Bluetooth 1.2 specification the Extended SCO feature for
    better audio connections was introduced. So far the Bluetooth core
    wasn't able to handle any eSCO connections correctly. This patch
    adds simple eSCO support while keeping backward compatibility with
    older devices.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 9f73edf6556372b2ca308a90b6e86c42c299572c 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 14:52:38 +0200 

    [Bluetooth] Add address and channel attribute to RFCOMM TTY device
    
    Export the remote device address and channel of RFCOMM TTY device
    via sysfs attributes. This allows udev to create better naming rules
    for configured RFCOMM devices.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 8ede11da710c41c82c15e706985a557b8925d412 
Author: Dave Young <hidave.darkstar@gmail.com> Sat, 20 Oct 2007 14:15:39 +0200 

    [Bluetooth] Fix wrong argument in debug code of HIDP
    
    In the debug code of the hidp_queue_report function, the device
    variable does not exist, replace it with session->hid.
    
    Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 40f8ebd22f42a2590983bfb44f79e2b8c0f8bbd3 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 14:12:34 +0200 

    [Bluetooth] Add generic driver for Bluetooth USB devices
    
    This patch adds a new generic driver for Bluetooth USB devices. This
    driver is still experimental at this point, but it is cleaner and
    easier to maintain than the current Bluetooth USB driver. It is a
    much better starting point for power management improvements.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 7206aecb43d34e533722b10619878aa073fd20c0 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 14:02:04 +0200 

    [Bluetooth] Add generic driver for Bluetooth SDIO devices
    
    This patch adds a generic driver for Bluetooth SDIO devices. It
    supports Type-A and Type-B devices.
    
    Signed-off-by: David Vrabel <david.vrabel@csr.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: bcce038d8f2cfe0bb6d470d6029aa239fc1b5d73 
Author: Jeff Garzik <jeff@garzik.org> Sat, 20 Oct 2007 13:45:57 +0200 

    [Bluetooth] Eliminate checks for impossible conditions in IRQ handler
    
    Our info structure and info->hdev is always passed to the IRQ handler,
    so we don't have to worry about these checks in every interrupt.
    
    Leave a BUG_ON() just to help unwary programmers, but these could
    probably be removed as well.
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: d9f2f1b6273c089aeeed183c77eb0d1837942438 
Author: Ohad Ben-Cohen <ohad@bencohen.org> Sat, 20 Oct 2007 13:42:36 +0200 

    [Bluetooth] Add UART driver for Texas Instruments' BRF63xx chips
    
    Add support for Texas Instruments' HCI Low Level (HCILL) Bluetooth
    protocol, which is a power management extension to H4. The HCILL is
    widely used by TI's BRF63xx Bluetooth chips.
    
    Signed-off-by: Ohad Ben-Cohen <ohad@bencohen.org>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 2bee5dbd7663fb87ad7c4dc3e5e738ecfb5df1e2 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:41:33 +0200 

    [Bluetooth] Change BPA 100/105 driver to use USB anchors
    
    With the new support for USB anchors the driver can become more
    simpler and also cleaner. This patch switches to the usage of USB
    anchors for all URBs.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 127a0a7997329bf68ee966cde4fb58ac691d66c9 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:39:51 +0200 

    [Bluetooth] Fall back to L2CAP in basic mode
    
    In case the remote entity tries to negogiate retransmission or flow
    control mode, reject it and fall back to basic mode.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: a57044011679d14754b258b329a8138bbb9f547e 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:38:51 +0200 

    [Bluetooth] Advertise L2CAP features mask support
    
    Indicate the support for the L2CAP features mask value when the remote
    entity tries to negotiate Bluetooth 1.2 specific features.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 28f5cb488d346fd700803900aea084d85914e5a5 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:37:56 +0200 

    [Bluetooth] Retrieve L2CAP features mask on connection setup
    
    The Bluetooth 1.2 specification introduced a specific features mask
    value to interoperate with newer versions of the specification. So far
    this piece of information was never needed, but future extensions will
    rely on it. This patch adds a generic way to retrieve this information
    only once per connection setup.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 24d08d292235803b93938727181491c2a2fe1782 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:37:06 +0200 

    [Bluetooth] Remove global conf_mtu variable from L2CAP
    
    After the change to the L2CAP configuration parameter handling the
    global conf_mtu variable is no longer needed and so remove it.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 938eb4feb80112b7b3bae0e958dc1d3573a6d926 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:35:42 +0200 

    [Bluetooth] Finish L2CAP configuration only with acceptable settings
    
    The parameters of the L2CAP output configuration might not be accepted
    after the first configuration round. So only indicate a finished output
    configuration when acceptable settings are provided.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 12389548391560538f19455ddec0fd7d8d10c8be 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 13:33:56 +0200 

    [Bluetooth] Switch from OGF+OCF to using only opcodes
    
    The Bluetooth HCI commands are divided into logical OGF groups for
    easier identification of their purposes. While this still makes sense
    for the written specification, its makes the code only more complex
    and harder to read. So instead of using separate OGF and OCF values
    to identify the commands, use a common 16-bit opcode that combines
    both values. As a side effect this also reduces the complexity of
    OGF and OCF calculations during command header parsing.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




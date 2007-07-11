From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.23
Date: Wed, 11 Jul 2007 10:09:23 +0200
Message-ID: <1184141363.4536.32.camel@aeonflux.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:55728 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440AbXGKIn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 04:43:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

these are the Bluetooth patches for the 2.6.23 kernel release. Please
pull and send them of to Linus.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c      |   88 ----------------------------------
 drivers/bluetooth/hci_usb.h      |    5 -
 drivers/bluetooth/hci_vhci.c     |    6 --
 include/net/bluetooth/hci.h      |   18 ++++++-
 include/net/bluetooth/hci_core.h |    5 +
 include/net/bluetooth/rfcomm.h   |    1 
 net/bluetooth/hci_conn.c         |   51 +++++++++----------
 net/bluetooth/hci_core.c         |  100 +++++++++++++++++++++++++++++++++++++--
 net/bluetooth/hci_event.c        |   29 ++++++++---
 net/bluetooth/rfcomm/tty.c       |   34 ++++++++++---
 10 files changed, 195 insertions(+), 142 deletions(-)

through these ChangeSets:

Commit: 5b7f990927fe87ad3bec762a33c0e72bcbf6841e 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 11 Jul 2007 09:51:55 +0200 

    [Bluetooth] Add basics to better support and handle eSCO links
    
    To better support and handle eSCO links in the future a bunch of
    constants needs to be added and some basic routines need to be
    updated. This is the initial step.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 8de0a15483b357d0f0b821330ec84d1660cadc4e 
Author: Ville Tervo <ville.tervo@nokia.com> Wed, 11 Jul 2007 09:23:41 +0200 

    [Bluetooth] Keep rfcomm_dev on the list until it is freed
    
    This patch changes the RFCOMM TTY release process so that the TTY is kept
    on the list until it is really freed. A new device flag is used to keep
    track of released TTYs.
    
    Signed-off-by: Ville Tervo <ville.tervo@nokia.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 84950cf0ba02fd6a5defe2511bc41f9aa2237632 
Author: Mikko Rapeli <mikko.rapeli@iki.fi> Wed, 11 Jul 2007 09:18:15 +0200 

    [Bluetooth] Hangup TTY before releasing rfcomm_dev
    
    The core problem is that RFCOMM socket layer ioctl can release
    rfcomm_dev struct while RFCOMM TTY layer is still actively using
    it. Calling tty_vhangup() is needed for a synchronous hangup before
    rfcomm_dev is freed.
    
    Addresses the oops at http://bugzilla.kernel.org/show_bug.cgi?id=7509
    
    Acked-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 924f0e4a06419fa1996425d1d2512030e43acbba 
Author: Robert P. J. Day <rpjday@mindspring.com> Wed, 11 Jul 2007 09:07:07 +0200

    [Bluetooth] Remove the redundant non-seekable llseek method
    
    Remove the llseek method given that the open method already calls
    nonseekable_open().
    
    Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: babf4d42d0a41ff58463b0a0515683cdce66f541 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 11 Jul 2007 06:42:35 +0200 

    [Bluetooth] Use hci_recv_fragment() within HCI USB driver
    
    This patch modifies the HCI USB driver to use the new helper function
    for reassembling HCI data packets and events.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: ef222013fc8c1a2fcba5c7ab169be8ffcb778ec4 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 11 Jul 2007 06:42:04 +0200 

    [Bluetooth] Add hci_recv_fragment() helper function
    
    Most drivers must handle fragmented HCI data packets and events. This
    patch adds a generic function for their reassembly to the Bluetooth
    core layer and thus allows to shrink the complexity of the drivers.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>




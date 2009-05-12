From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-05-11
Date: Mon, 11 May 2009 20:06:54 -0700
Message-ID: <1242097614.2970.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47831 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757570AbZELDHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 23:07:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

unfortunately I do have three more patches for the 2.6.30 release. The
guys from Nokia are heavily testing this release to make sure that even
the smallest regression or race condition is reported and fixed. And I
am thankful for this since some of these cases only happen with specific
devices out in the market. And while I own a lot of Bluetooth devices,
it is only a small portion :)

We do have a broken module reference counting that got introduced when
trying to fix a lifetime issue with the hci_dev structure. It races
against the sysfs handling inside the work queue. To fix this, split the
reference counting and let the work queue task hold its own.

We call hci_acl_connect_cancel() for an incoming connection. That is
just wrong since their is nothing to cancel. Incoming connections can be
either accepted or reject. Once accepted, their is nothing to cancel.
Only a disconnect would be working.

The security mode 3 with legacy devices triggered another regression
with the pairing timeout. So only use the pairing timeout if the
connection is fully connected. In the security mode 3 the pairing
happens between the connection attempt and completion. And that phase
uses a proper timeout already, so no need to add extra code for special
pairing timeout handling.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 net/bluetooth/hci_conn.c  |    6 +++---
 net/bluetooth/hci_event.c |    2 +-
 net/bluetooth/hci_sysfs.c |    3 +++
 3 files changed, 7 insertions(+), 4 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    Bluetooth: Fix wrong module refcount when connection setup fails
    Bluetooth: Don't use hci_acl_connect_cancel() for incoming connections
    Bluetooth: Don't trigger disconnect timeout for security mode 3 pairing




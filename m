From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2010-03-21
Date: Sun, 21 Mar 2010 06:41:34 +0100
Message-ID: <cover.1269149354.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35324 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab0CUFlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 01:41:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these patches fix a potential remote denial of service in the L2CAP
layer and a potential bad memory access with some sysfs files.

As agreed with Linus, I fixed the sysfs issue in two steps. The first
patch just avoids the invalid memory access while accepting that the
content might be truncated. The second patch moves everything over to
debugfs (where these files belong anyway) and switches to seq_file.

This two step approach allows an easy backport to -stable kernel by
only picking the first patch.

Linus, feel free to pull directly since both patches are security
related and should be merged as quickly as possible.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 include/net/bluetooth/bluetooth.h |    2 +-
 net/bluetooth/hci_sysfs.c         |    3 +-
 net/bluetooth/l2cap.c             |   48 +++++++++++++++++++++++++++----------
 net/bluetooth/rfcomm/core.c       |   41 ++++++++++++++++++++++---------
 net/bluetooth/rfcomm/sock.c       |   38 ++++++++++++++++++++--------
 net/bluetooth/sco.c               |   38 ++++++++++++++++++++---------
 6 files changed, 119 insertions(+), 51 deletions(-)

through these ChangeSets:

Andrei Emeltchenko (1):
    Bluetooth: Fix kernel crash on L2CAP stress tests

Marcel Holtmann (2):
    Bluetooth: Fix potential bad memory access with sysfs files
    Bluetooth: Convert debug files to actually use debugfs instead of sysfs


From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth fixes for 2.6.27
Date: Mon, 08 Sep 2008 23:53:57 +0200
Message-ID: <1220910837.11655.28.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43083 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbYIHVxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 17:53:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I do have three additional fixes for the Bluetooth subsystem that should
go into the 2.6.27 release. After the heated discussion, I really wanted
not to bother you until the next merge window, but from my perspective
all three patches fall in the regression or security fix category. That
is my personal view on these and feel free to disagree.

The first patch is a clear regression that got introduced with
2.6.27-rc1 when adding Simple Pairing support. I forgot to decrease the
reference count on an incoming ACL link. This patch actually makes the
code simpler.

The second patch fixes the authentication requirements. We do have to
separate between service discovery and actual profile channels. This is
a clear requirement of the Bluetooth Security Mode 4 introduced with the
addition of the Simple Pairing support. Not fixing this will result in
broken behavior when doing service discovery with Simple Pairing enabled
devices.

The third patch rejects insecure incoming connections. This is a clear
security issues since we can't rely on the initiator doing the right
thing and establishing an encrypted link. Malicious devices would just
skip that step and in that case we have to reject connection attempt
without going into the connection phase at all.

I tried to put detailed information into the commit messages to make it
clear why I submitted these patches in the -rc phase.

We do have one suspend/resume regression with the btusb driver that I
like to see fixed, but the fix would require new USB core functionality.
I am not sure if that happens in the 2.6.27 timeframe. I will check with
Oliver if we can come up with a patch that works with the current
kernel.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 include/net/bluetooth/hci_core.h |    3 ++-
 net/bluetooth/af_bluetooth.c     |    2 +-
 net/bluetooth/hci_conn.c         |   21 ++++++++++++++++++---
 net/bluetooth/hci_event.c        |   11 ++++-------
 net/bluetooth/l2cap.c            |   34 ++++++++++++++++++++++++++++------
 net/bluetooth/sco.c              |    2 +-
 6 files changed, 54 insertions(+), 19 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    [Bluetooth] Fix reference counting during ACL config stage
    [Bluetooth] Enforce correct authentication requirements
    [Bluetooth] Reject L2CAP connections on an insecure ACL link



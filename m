From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [RFC PATCH 0/2] unify full duplex flow control resolution
Date: Sun, 14 Dec 2008 12:38:19 +0000
Message-ID: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:59730 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752447AbYLNMiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 07:38:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

4 drivers (tg3, smsc911x, smsc9420 & smsc9500) have identical full 
duplex flow control resolution functions (primarily because I re-used
tg3's implementation for the 3 SMSC drivers).  This patchset moves this 
to an inline function in mii.h and changes the 4 drivers to use it.

It's a small enough function, and it's only used once in each driver,
but I'm still not completely sure inline is right.  These drivers 
don't all have a dependency on mii.c though, and I wanted to avoid 
adding this to the SMSC drivers that have been converted to phylib.

--
Steve Glendinning (2):
  move flow control definitions to mii.h
  refactor full duplex flow control resolution

 drivers/net/smsc911x.c     |   24 +-------------
 drivers/net/smsc911x.h     |    3 --
 drivers/net/smsc9420.c     |   24 +-------------
 drivers/net/smsc9420.h     |    3 --
 drivers/net/tg3.c          |   74 +++++++++++++++----------------------------
 drivers/net/tg3.h          |    2 -
 drivers/net/usb/smsc95xx.c |   26 +---------------
 include/linux/mii.h        |   33 +++++++++++++++++++
 8 files changed, 62 insertions(+), 127 deletions(-)


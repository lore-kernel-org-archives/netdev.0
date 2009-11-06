From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC, PATCH 0/7] net, compat_ioctl: move handlers to net/socket.c
Date: Fri,  6 Nov 2009 19:09:02 +0100
Message-ID: <1257530949-9695-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Christoph Hellwig <hch@lst.de>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759549AbZKFSKS@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This cleans up some of the socket ioctl handling by moving it
from fs/compat_ioctl.c to net/socket.c. The code is still untested,
so this is an RFC for now. If you're happy with it, I'll do some
testing to see if everything still works.

This series is a prerequisite for cleaning up the rest of
compat_ioctl.c, saving some 30kb of kernel memory in the end.

The first four patches are probably worthwhile independently,
because they fix some bugs in compat_ioctl handling.
There is some obvious conflict with the ATM patch I sent
independently today. That one should probably be worked out
first.

	Arnd <><

---

Arnd Bergmann (7):
  compat: add struct compat_ifreq etc to compat.h
  net/tun: handle compat_ioctl directly
  net, compat_ioctl: handle socket ioctl abuses in tty drivers
  appletalk:=C2=A0handle SIOCATALKDIFADDR compat ioctl
  copy socket ioctl code to net/socket.h
  compat: move sockios handling to net/socket.c
  net, compat_ioctl: handle more ioctls correctly

 drivers/net/hamradio/6pack.c |   16 +
 drivers/net/hamradio/mkiss.c |   16 +
 drivers/net/slip.c           |   21 ++
 drivers/net/tun.c            |   55 +++-
 drivers/net/wan/x25_asy.c    |   15 +
 drivers/net/wireless/strip.c |   12 +
 fs/compat_ioctl.c            |  745 ----------------------------------=
-------
 include/linux/compat.h       |   39 +++
 net/appletalk/ddp.c          |   12 +-
 net/socket.c                 |  748 ++++++++++++++++++++++++++++++++++=
+++++++-
 10 files changed, 914 insertions(+), 765 deletions(-)

From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 00/12] more BKL removal after get_sb pushdown
Date: Thu, 16 Sep 2010 19:46:13 +0200
Message-ID: <1284659185-8942-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@suse.de>,
	Jan Blunck <jblunck@infradead.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
	"H. Peter Anvin" <hpa@zytor.com>, reiserfs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-usb@vger.kernel.org, linux-afs@lists.infradead.org,
	David Howells <dhowells@redhat.com>,
	Dustin Kirkland <kirkland@canonical.com>,
	Tyler Hicks <tyhicks@linux.vnet.ibm.com>,
	ecryptfs-devel@lists.launchpad.net,
	David Woodhouse <dwmw2@infradead.org>,
	Phillip Lougher <phillip@lougher.demon.co.uk>,
	Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <joel.becker@oracle.com>,
	linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches have not been posted yet, I did some of them
only when going through the list of remaining BKL users and
found them to be simple to fix myself.

Most of these patches only apply on top of the pushdown into
the get_sb operation, which is now in linux-next, so I'm
planning to keep them in the same series instead of
going through maintainer trees.

The full series can be found in
git://git.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git vfs

Arnd Bergmann (12):
  BKL: Remove BKL from usbfs
  BKL: Remove BKL from fat
  BKL: Remove BKL from isofs
  BKL: Remove BKL from autofs4
  BKL: Remove BKL from ReiserFS
  BKL: Remove BKL from capifs
  BKL: Remove BKL from USB gadgetfs
  BKL: Remove BKL from afs
  BKL: Remove BKL from ecryptfs
  BKL: Remove BKL from jffs2
  BKL: Remove BKL from squashfs
  BKL: Remove BKL from OCFS2

 drivers/isdn/capi/capifs.c |    8 +-------
 drivers/usb/core/inode.c   |    6 ------
 drivers/usb/gadget/inode.c |   13 ++-----------
 fs/afs/super.c             |   10 ----------
 fs/autofs4/root.c          |   12 +++++++-----
 fs/ecryptfs/file.c         |    3 ---
 fs/ecryptfs/main.c         |    4 ----
 fs/fat/inode.c             |    5 -----
 fs/fat/namei_msdos.c       |    7 +++----
 fs/fat/namei_vfat.c        |    7 +++----
 fs/isofs/dir.c             |    6 +++---
 fs/isofs/inode.c           |   16 ++++++----------
 fs/isofs/namei.c           |    8 ++++----
 fs/isofs/rock.c            |    8 ++++----
 fs/jffs2/fs.c              |    4 ----
 fs/jffs2/super.c           |   12 +-----------
 fs/ocfs2/dlmfs/dlmfs.c     |    9 +--------
 fs/ocfs2/stack_user.c      |    3 ---
 fs/ocfs2/super.c           |   12 ------------
 fs/reiserfs/super.c        |    6 ------
 fs/squashfs/super.c        |   11 -----------
 21 files changed, 35 insertions(+), 135 deletions(-)

Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Jan Blunck <jblunck@infradead.org>
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Blunck <jblunck@infradead.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: reiserfs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: David Brownell <dbrownell@users.sourceforge.net>
Cc: linux-usb@vger.kernel.org
Cc: linux-afs@lists.infradead.org
Cc: David Howells <dhowells@redhat.com>
Cc: Dustin Kirkland <kirkland@canonical.com>
Cc: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
Cc: ecryptfs-devel@lists.launchpad.net
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Phillip Lougher <phillip@lougher.demon.co.uk>
Cc: Mark Fasheh <mfasheh@suse.com>
Cc: Joel Becker <joel.becker@oracle.com>
Cc: linux-fsdevel@vger.kernel.org

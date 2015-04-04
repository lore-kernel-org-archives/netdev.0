From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-04-04
Date: Sat, 4 Apr 2015 09:24:06 +0300
Message-ID: <20150404062406.GA29882@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's what's probably the last bluetooth-next pull request for 4.1:

 - Fixes for LE advertising data & advertising parameters
 - Fix for race condition with HCI_RESET flag
 - New BNEPGETSUPPFEAT ioctl, needed for certification
 - New HCI request callback type to get the resulting skb
 - Cleanups to use BIT() macro wherever possible
 - Consolidate Broadcom device entries in the btusb HCI driver
 - Check for valid flags in CMTP, HIDP & BNEP
 - Disallow local privacy & OOB data combo to prevent a potential race
 - Expose SMP & ECDH selftest results through debugfs
 - Expose current Device ID info through debugfs

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit a7a484bfca218f9671a3e3bc98851eab6b628310:

  at86rf230: fix is_tx while error handling (2015-03-27 19:18:51 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 38c8af60046edab4c9db5f26e79746b1bd52c837:

  Bluetooth: Fix location of TX power field in LE advertising data (2015-04-04 08:50:20 +0300)

----------------------------------------------------------------
Arman Uguray (3):
      Bluetooth: Fix using global connectable settings for adv
      Bluetooth: Use ADV_SCAN_IND for adv. instances
      Bluetooth: Update adv. parameters when conn. setting changes

Grzegorz Kolodziejczyk (4):
      Bluetooth: bnep: Return err value while sending cmd is not understood
      Bluetooth: bnep: Add support for get bnep features via ioctl
      Bluetooth: bnep: Add support to extended headers of control frames
      Bluetooth: bnep: Handle BNEP connection setup request

Johan Hedberg (10):
      Bluetooth: Fix race condition with HCI_RESET flag
      Bluetooth: Refactor L2CAP variables into l2cap_ctrl
      Bluetooth: Refactor HCI request variables into own struct
      Bluetooth: Add clarifying comment to command status handling
      Bluetooth: Add second hci_request callback option for full skb
      Bluetooth: Convert hci_req_sync family of function to new request API
      Bluetooth: Remove unneeded recv_event variable
      Bluetooth: Remove unused hci_req_pending() function
      Bluetooth: Move hci_get_cmd_complete() to hci_event.c
      Bluetooth: Convert local OOB data reading to use HCI request

Marcel Holtmann (15):
      Bluetooth: btusb: Consolidate Broadcom based device entries
      Bluetooth: Move memory location outside of hci_dev lock
      Bluetooth: Fix error returns for Read Local OOB Extended Data commands
      Bluetooth: Remove superfluous extra empty line between functions
      Bluetooth: Expose current Device ID information via debugfs
      Bluetooth: Remove unneeded extra ( ) in valid flags check
      Bluetooth: Restrict CMTP flags to only valid ones
      Bluetooth: Restrict HIDP flags to only valid ones
      Bluetooth: Restrict BNEP flags to only valid ones
      Bluetooth: Export ECDH selftest result in debugfs
      Bluetooth: Export SMP selftest result in debugfs
      Bluetooth: Disallow LE local out-of-band data when LE privacy is used
      Bluetooth: cmtp: Use BIT(x) instead of (1 << x)
      Bluetooth: hidp: Use BIT(x) instead of (1 << x)
      Bluetooth: Fix location of TX power field in LE advertising data

 drivers/bluetooth/btusb.c         |  12 +-
 drivers/bluetooth/hci_ldisc.c     |   2 +-
 fs/compat_ioctl.c                 |   2 +
 include/net/bluetooth/bluetooth.h |  23 +++-
 include/net/bluetooth/hci_core.h  |   7 +-
 net/bluetooth/bnep/bnep.h         |   4 +
 net/bluetooth/bnep/core.c         |  70 ++++++++--
 net/bluetooth/bnep/sock.c         |   7 +
 net/bluetooth/cmtp/capi.c         |   2 +-
 net/bluetooth/cmtp/core.c         |  15 ++-
 net/bluetooth/hci_core.c          | 120 +++++------------
 net/bluetooth/hci_debugfs.c       |  26 ++++
 net/bluetooth/hci_event.c         | 175 ++++++++++++++++--------
 net/bluetooth/hci_request.c       |  20 ++-
 net/bluetooth/hci_request.h       |   5 +-
 net/bluetooth/hci_sock.c          |   2 +-
 net/bluetooth/hidp/core.c         |  15 ++-
 net/bluetooth/l2cap_core.c        |  48 +++----
 net/bluetooth/l2cap_sock.c        |   6 +-
 net/bluetooth/mgmt.c              | 267 +++++++++++++++++++++++--------------
 net/bluetooth/selftest.c          |  35 ++++-
 net/bluetooth/smp.c               |  45 +++++--
 22 files changed, 570 insertions(+), 338 deletions(-)


--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVH4OGAAoJECQj9vv5qNQSm6AP/jsWbz7brrAy4jXqdXgae+n9
eglRXnjD5y3Rz25zuPhbEkj1wU807FG0FYe+13IRZTG5ouf0g3WjTLVS7dp/KZ0A
Xt6Mn/HiNqGbTU6Xodb/px/xvK9blyyVOeHEhXW2pBPLTtEYFSq1T1fAKlWN/sCz
1DoLegh5uDq0DretBLqIhGGfYye7WhaMiDsFUvsN8WwQJNBC3Hca8VRN8d16pKYy
LL+L3pe9OxVtnkGeAj+RS19GoyK4RLwm4pktUcmxBsCVEhwhOtmb3fzPHGLqtFgm
jMmOLLccnw+ZRWYxcnQq7hQZw4ThSJgZijeV5db9LEwife23LZqtAHywRQAY4z/m
EMQkvZFggByoQarZLWnGPTa3LE1U32nXNfpBgVl5SiVCuAYN3fYih0QNqQAue9Ty
y2QJ5hQbHMV9votHCsb0RMfH9mwTKz8RPmyhqcXhrRNeciB634VfjJajNZhhoiZy
Sj/0bac5AEeTL7MnBzjfowwhpyRzGwJIoKReD1sG/jj4Ji3pr9ZM5CJ63JufZdgp
xOC9IViYdcnQA5lMqJ/gf/Z2mfBleEuOqcNFUq3UCVaridjfv1QcKQ7ILGierGlr
7U51ohiHFjS5Qfpp2ORbU9oidFBHlJn/h6s5u0XJsQyd/vSNRhcrto7suXmFenAh
MaE74xuMtZ/8BJkHv1zj
=LMlT
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--

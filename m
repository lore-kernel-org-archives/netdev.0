From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 0/2] The Long Lost TUN LSM Hooks
Date: Tue, 04 Aug 2009 17:21:46 -0400
Message-ID: <20090804211304.10798.65601.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:43876 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbZHDVWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 17:22:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While drivers in general aren't good places for LSM hooks the TUN driver is
a bit different because of how it handles sockets and network traffic.  The
problem lies in the fact that the TUN driver creates a sock structure to use
when sending network traffic but the sock is never put through the same LSM
setup/control as other sock structures on the system which makes enforcing
security on TUN generated traffic difficult for some LSMs.  This patch set
adds three new LSM hooks, all specific to the TUN driver (none of the existing
hooks made sense, trust me we tried), to control and monitor the creating and
attachment of TUN devices.

The necessary support for SELinux is also included in this patch with support
for Smack and TOMOYO absent; although I suspect there will be no changes needed
for either of those LSMs.

--

NOTE: These patches are truly RFC, please let me know how you feel about these
      new hooks.  I've booted a kernel with these changes but I'm having some
      problems today with my Rawhide/KVM test machine so I'm having mixed luck
      testing this - no regressions, but no real TUN testing either.

---

Paul Moore (2):
      selinux: Support for the new TUN LSM hooks
      lsm: Add hooks to the TUN driver


 drivers/net/tun.c                          |   41 ++++++++-------
 include/linux/security.h                   |   34 +++++++++++++
 security/commoncap.c                       |   26 ++++++++++
 security/security.c                        |   18 +++++++
 security/selinux/hooks.c                   |   76 +++++++++++++++++++++++++++-
 security/selinux/include/av_inherit.h      |    1 
 security/selinux/include/av_permissions.h  |   22 ++++++++
 security/selinux/include/class_to_string.h |    1 
 security/selinux/include/flask.h           |    1 
 security/selinux/include/security.h        |    2 +
 security/selinux/selinuxfs.c               |    3 +
 security/selinux/ss/services.c             |    3 +
 12 files changed, 207 insertions(+), 21 deletions(-)


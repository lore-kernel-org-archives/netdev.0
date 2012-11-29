From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 0/2] Fix some multiqueue TUN problems
Date: Thu, 29 Nov 2012 17:06:21 -0500
Message-ID: <20121129215724.30020.69464.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab2K2WGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 17:06:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A relatively short patchset to fix some problems that have arisen from
the multiqueue TUN work.  I'm sending this a RFC for now as it changes
the LSM TUN interfaces and therefore crosses a few boundaries,
e.g. SELinux, although it does so only in an effort to restore the
original behavior which was lost in the multiqueue conversion.

I'm not particularly enthused with the idea of passing a void** as a
parameter to security_tun_dev_alloc_security() but the alternatives
would be to move the tun_struct out of tun.c or have the LSM interface
return a pointer (which would require us to return a "fake" non-NULL
pointer when the LSM was disabled) ... neither of these seemed like good
alternatives to me.

I've compiled the code and booted it without drama, but I haven't really
stressed it too much so buyer beware at this point.  Comments are always
welcome ...

---

Paul Moore (2):
      tun: correctly report an error in tun_flow_init()
      tun: fix LSM/SELinux labeling of tun/tap devices


 drivers/net/tun.c                 |   16 ++++++++++----
 include/linux/security.h          |   37 ++++++++++++++++++++++-----------
 security/capability.c             |   14 +++++++++---
 security/security.c               |   22 ++++++++++++-------
 security/selinux/hooks.c          |   42 +++++++++++++++++++++++--------------
 security/selinux/include/objsec.h |    4 ++++
 6 files changed, 90 insertions(+), 45 deletions(-)

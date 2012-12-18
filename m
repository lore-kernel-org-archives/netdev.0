From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH v3 0/2] Fix some multiqueue TUN problems
Date: Tue, 18 Dec 2012 17:53:37 -0500
Message-ID: <20121218225001.16104.34454.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278Ab2LRWxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 17:53:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A refresh/respin of the LSM/SELinux fixes to work on top of Jason's
latest API tweak (now living in DaveM's net tree).  In general, I
believe the hooks and thinking behind the v2 patchset still make sense
so no changes there, although I did change the SELinux permission from
"create_queue" to "attach_queue" to match the API changes.

Comments are welcome and encouraged; we need to get this fixed before
3.8 is released.

---

Paul Moore (2):
      selinux: add the "attach_queue" permission to the "tun_socket" class
      tun: fix LSM/SELinux labeling of tun/tap devices


 drivers/net/tun.c                   |   27 ++++++++++++----
 include/linux/security.h            |   59 +++++++++++++++++++++++++++--------
 security/capability.c               |   24 ++++++++++++--
 security/security.c                 |   28 ++++++++++++++---
 security/selinux/hooks.c            |   50 +++++++++++++++++++++++-------
 security/selinux/include/classmap.h |    2 +
 security/selinux/include/objsec.h   |    4 ++
 7 files changed, 155 insertions(+), 39 deletions(-)

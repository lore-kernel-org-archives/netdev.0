From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH v2 0/2] Fix the SELinux dynamic network access controls
Date: Fri, 24 May 2013 14:16:16 -0400
Message-ID: <20130524181430.24022.15997.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: omoris@redhat.com, pwouters@redhat.com
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3EXSQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 14:16:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bump to v2 to incorporate Sergei's minor comment on the previous
patchset.  I've also gone ahead and dropped the "RFC" from the
patchset as I didn't see any significant comments/concerns from
anyone.

---

Paul Moore (2):
      selinux: fix the labeled xfrm/IPsec reference count handling
      xfrm: force a garbage collection after deleting a policy


 include/linux/security.h        |   26 ++-
 include/net/xfrm.h              |    5 +
 net/key/af_key.c                |    4 
 net/xfrm/xfrm_policy.c          |    3 
 net/xfrm/xfrm_user.c            |    2 
 security/capability.c           |   15 +-
 security/security.c             |   13 -
 security/selinux/hooks.c        |    5 -
 security/selinux/include/xfrm.h |    8 +
 security/selinux/xfrm.c         |  384 ++++++++++++++++++---------------------
 10 files changed, 230 insertions(+), 235 deletions(-)

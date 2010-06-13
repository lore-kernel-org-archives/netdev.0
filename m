From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/8] Support unix domain sockets across namespaces
Date: Sun, 13 Jun 2010 06:25:32 -0700
Message-ID: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39585 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab0FMNZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset takes a addressing all of the issues that crop up with
unix domain sockets when the senders and receivers are in separate
namespaces.

Without this patchset we can report the wrong pid and uid
values in our unix domain credentials.

As a finally this patchset removes the now unnecessary restriction
that we only allow unix domain sockets between processes in the
same network namespace.

Eric W. Biederman (8):
      scm: Reorder scm_cookie.
      user_ns: Introduce user_nsmap_uid and user_ns_map_gid.
      sock: Introduce cred_to_ucred
      af_unix: Allow SO_PEERCRED to work across namespaces.
      af_netlink: Add needed scm_destroy after scm_send.
      scm: Capture the full credentials of the scm sender.
      af_unix: Allow credentials to work across user and pid namespaces.
      af_unix: Allow connecting to sockets in other network namespaces.

---
 include/linux/socket.h         |    5 ++
 include/linux/user_namespace.h |   14 ++++++
 include/net/af_unix.h          |    4 +-
 include/net/scm.h              |   30 ++++++++++--
 include/net/sock.h             |    3 +-
 kernel/user_namespace.c        |   44 ++++++++++++++++++
 net/core/scm.c                 |   24 ++++++++++
 net/core/sock.c                |   32 +++++++++++---
 net/netlink/af_netlink.c       |   11 +++-
 net/unix/af_unix.c             |   97 +++++++++++++++++++++++++---------------
 10 files changed, 211 insertions(+), 53 deletions(-)

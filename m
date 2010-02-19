From: Florian Westphal <fwestphal@astaro.com>
Subject: [PATCH v2 0/5] xfrm: add x86 CONFIG_COMPAT support
Date: Fri, 19 Feb 2010 13:41:42 +0100
Message-ID: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Cc: johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:48613 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312Ab0BSMlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:41:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2nd version of xfrm x86-compat patch set.

please refer to the individual patches for the list of
changes since v1.

At the moment it is not possible to use the xfrm netlink interface on
x86_64 with a 32bit userland.

The problem exists because a few structures, e.g. struct xfrm_usersa_info,
have different sizes in user/kernelspace (3 byte padding on x86, 7
byte on x86_64) due to different alignment requirements of "u64".

First two patches add necessary CONFIG_COMPAT_NETLINK_MESSAGES
infrastructure to netlink in/output path.

Patch 3 is a refactoring patch to split functionality (especially
nlmsg allocation and adding data to the nlmsg) in order to
re-use code and ease review.

Patch 4 adds CONFIG_COMPAT_FOR_U64_ALIGNMENT support to xfrm.

Patch 5 sets CMSG_MSG_COMPAT in sock_aio_write(), depending on
is_compat_task().  If patch 5 is deemed too ugly, just pretend it
doesn't exist; userspace can be patched to use sendmsg instead of
write() to fix the problem, too.

 include/linux/netlink.h  |    1 
 net/netlink/af_netlink.c |   11 +
 net/socket.c             |    4 
 net/xfrm/Kconfig         |    1 
 net/xfrm/xfrm_user.c     |  505 +++++++++++++++++++++++++++++++++++++++++------
 5 files changed, 462 insertions(+), 60 deletions(-)

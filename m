From: luciano.coelho@nokia.com
Subject: [PATCH v2 0/2] netfilter: xtables: xt_condition inclusion and change to u32
Date: Fri,  6 Aug 2010 15:21:46 +0300
Message-ID: <1281097308-1515-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:18616 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760917Ab0HFMWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 08:22:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <luciano.coelho@nokia.com>

Hello,

Here v2 of the xt_condition patch, it contains some changes suggested by Jan.

When these patches get accepted, I'll send the implementation of the condition
target, as discussed before.

In RFC v2 I've made a few changes as discussed in the review:

  * Removed per-netns module parameters
  * Use par->net instead of current->nsproxy->net_ns
  * Fix file-leak in procfs when exiting the netns

I didn't get any more comments in RFC v2, so I assume it is okay to send it for
inclusion.

>From [RFC v2] to [PATCH], I've only rebased and added a new patch to support
u32 instead of boolean as the value for the condition.

In PATCH v2:

  * Bumped up the revision to 2
  * Changed the buffer declaration to have the size of the biggest possible u32 string
  * Return -ERANGE instead of -EINVALID when the value passed is too big.

Cheers,
Luca.


Luciano Coelho (2):
  netfilter: xtables: inclusion of xt_condition
  netfilter: xt_condition: change the value from boolean to u32

 include/linux/netfilter/Kbuild         |    1 +
 include/linux/netfilter/xt_condition.h |   15 ++
 net/netfilter/Kconfig                  |    8 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_condition.c           |  269 ++++++++++++++++++++++++++++++++
 5 files changed, 294 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_condition.h
 create mode 100644 net/netfilter/xt_condition.c


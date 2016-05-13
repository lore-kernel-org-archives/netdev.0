From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH v2 net-next 0/2] Enable SW only or HW only offloads with u32 classifier
Date: Thu, 12 May 2016 17:08:21 -0700
Message-ID: <1463098103-2434-1-git-send-email-sridhar.samudrala@intel.com>
To: john.r.fastabend@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:26690 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753017AbcEMANh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 20:13:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches export TCA_CLS_FLAGS_SKIP_HW to userspace and also
introduces another flag TCA_CLS_FLAGS_SKIP_SW. These flags enable offloading 
u32 filters to either SW or HW only.

The default semantics with no flags is to add the filter to HW if possible and
also into SW. 
With SKIP_HW flag, the filter is only added to SW.
With SKIP_SW flag, the filter is added to HW and an error is returned
to user on failure.
These flags are mutually exclusive.
There was an earlier discussion on these semantics in the following email
thread.
	http://thread.gmane.org/gmane.linux.network/401733

Sridhar Samudrala (2):
  Move TCA_CLS_FLAGS_SKIP_HW to uapi header file.
  Add support for skip-sw flag to tc u32 classifier.

 include/net/pkt_cls.h        | 20 +++++++++++++++++---
 include/uapi/linux/pkt_cls.h |  4 ++++
 net/sched/cls_u32.c          | 45 +++++++++++++++++++++++++++++++++++---------
 3 files changed, 57 insertions(+), 12 deletions(-)

-- 
2.1.0

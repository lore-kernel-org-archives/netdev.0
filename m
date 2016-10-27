From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 0/3] Add support for XPS when using DCB
Date: Thu, 27 Oct 2016 11:39:59 -0400
Message-ID: <20161027153539.13989.14349.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, tom@herbertland.com,
        intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:5216 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936241AbcJ0Vks (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 17:40:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables proper isolation between traffic classes when
using XPS while DCB is enabled.  Previously enabling XPS would cause the
traffic to be potentially pulled from one traffic class into another on
egress.  This change essentially multiplies the XPS map by the number of
traffic classes and allows us to do a lookup per traffic class for a given
CPU.

To guarantee the isolation I invalidate the XPS map for any queues that are
moved from one traffic class to another, or if we change the number of
traffic classes.

---

Alexander Duyck (3):
      net: Move functions for configuring traffic classes out of inline headers
      net: Refactor removal of queues from XPS map and apply on num_tc changes
      net: Add support for XPS with QoS via traffic classes


 include/linux/netdevice.h |   36 +------
 net/core/dev.c            |  228 +++++++++++++++++++++++++++++++++++----------
 net/core/net-sysfs.c      |   31 ++++--
 3 files changed, 202 insertions(+), 93 deletions(-)

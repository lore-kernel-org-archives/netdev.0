From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 0/9] New cxgb4vf network driver for Chelsio T4 Virtual Function NIC
Date: Fri, 25 Jun 2010 15:07:48 -0700
Message-ID: <201006251507.48604.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2832 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab0FYWHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:07:49 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PM7n9N019360
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:07:49 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series introduces a new network driver for the Chelsio T4 PCI-E
SR-IOV Virtual Function NIC.  The patches are against net-next as of commit
39c9cf07077146b14ab077a0e27c869c6f0e6199.

This driver "depends" on the cxgb4 NIC driver only in-so-far as the cxgb4
driver needs to "provision" chip resources for each of the Virtual Functions
and the cxgb4 driver must enable the PCI-E SR-IOV functionality.  After that
the new "cxgb4vf" driver operates completely independently.  (It will often
be the case that the cxgb4vf driver will be operating withing a Virtual
Machine via "PCI Pass Through."

This is my first submission to Linux so I apologize in advance for any
mistakes.  I looked at many submissions to see how to do this but I
anticipate that I've almost certainly missed something critical.  Please
correct me on anything I've done wrong and I will happily fix them.  Thanks
in advance for you patience and understanding.

There is one part of this submission where I needed to make a big guess
regarding driver policies and procedures so I'll draw your attention to
that.  There are several header files which both the cxgb4 and cxgb4vf
drivers need to operate (T4 hardware register definitions, message
structures, etc.)  This patch series leaves those files in place within the
cxgb4 driver directory (with a few tiny modifications to add new
definitions) and the cxgb4vf driver includes them via "../cxgb4/xxx.h" I
found a couple of similar usages but I couldn't determine what the official
policy was.

Again, thank you for your time and consideration.

Casey Leedom

 drivers/net/Kconfig                |   23 +
 drivers/net/Makefile               |    1 +
 drivers/net/cxgb4/cxgb4_main.c     |  106 ++
 drivers/net/cxgb4/t4_hw.c          |    2 +-
 drivers/net/cxgb4/t4_hw.h          |   39 +
 drivers/net/cxgb4/t4_regs.h        |    3 +
 drivers/net/cxgb4/t4fw_api.h       |   27 +-
 drivers/net/cxgb4vf/Makefile       |    7 +
 drivers/net/cxgb4vf/adapter.h      |  540 +++++++
 drivers/net/cxgb4vf/cxgb4vf_main.c | 2906 ++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4vf/sge.c          | 2460 ++++++++++++++++++++++++++++++
 drivers/net/cxgb4vf/t4vf_common.h  |  273 ++++
 drivers/net/cxgb4vf/t4vf_defs.h    |  121 ++
 drivers/net/cxgb4vf/t4vf_hw.c      | 1333 +++++++++++++++++
 14 files changed, 7834 insertions(+), 7 deletions(-)

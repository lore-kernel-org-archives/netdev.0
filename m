From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [RFC v2 net-next 00/10] Add new drivers: qed & qede
Date: Thu, 17 Sep 2015 17:23:49 +0300
Message-ID: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32939 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751706AbbIQOY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 10:24:26 -0400
Received: from pps.filterd (m0085408.ppops.net [127.0.0.1])
	by mx0b-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t8HEKu7J026436
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 07:24:26 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0b-0016ce01.pphosted.com with ESMTP id 1wvk1nre4s-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 07:24:26 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <Ariel.Elior@qlogic.com>

This series implements the driver set for Qlogic's new 579xx series.
These are 10/20/25/40/50/100 Gig capable converged nics, supporting
ethernet (obviously), iscsi, fcoe, roce and iwarp protocols.

The overall driver design includes a common module ('qed') and protocol
specific dependent modules for ethernet ('qede'), fcoe ('qedf'),
iscsi ('qedi') and roce ('qedr').
The common module contains all of the common logic, e.g. initialization,
cleanup, infrastructure for interrupt handling, link management, slowpath
etc. as well as protocol agnostic features, and supplying an abstraction
layer for other modules.
The protocol specific modules can be compiled and operated independently
of each other, with the exception of the rdma modules which are dependent
on the ethernet module, in accordance with the kernel rdma stack design.

This series only adds the core and ethernet modules, with basic L2
capabilities. Future series will add the rest of the modules and enhance
the L2 functionality.

Ths patch series is constructed of the following patches:
qed:  Add module with basic common support
qed:  Add basic L2 interface
qede: Add basic Network driver
qed:  Add slowpath L2 support
qede: Add basic network device support
qede: Add classification configuration
qed:  Add link support
qede: Add support for link
qed:  Add statistics support
qede: Add basic ethtool support

We don't expect the series to be accepted as is. We are looking for
upstream community feedback and guidance. Although the series is quite
large, it is what we viewed as the minimal set of patches to constitute
a basic L2 driver.

This project is a team effort, thanks go to Yuval Mintz, Dmitry Kravkov,
Michal Kalderon, Tomer Tayar, Manish Chopra, Sudarsana Kalluru,
Rajesh Borundia, Sony Chacko, Artum Zolotushko, Harish Patil, Rasesh Mody,
Sergey Ukhterov and Elad Manela, as well as former team members,
Eilon Greenstein and Shmulik Ravid.

Changes from previos version:
-----------------------------

>From Version 1:
  - Removed private license file; Instead revised comments at source headers.

Thanks,
Ariel Elior

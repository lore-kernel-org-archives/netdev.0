From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [RFC v3 net-next 00/10] Add new drivers: qed & qede
Date: Wed, 30 Sep 2015 16:03:27 +0300
Message-ID: <1443618217-18069-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:1150 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932145AbbI3NDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 09:03:43 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t8UD35wb001279
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:03:42 -0700
Received: from avcashub1.qlogic.com (avcashub2.qlogic.com [198.70.193.116])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1x5tguwa1g-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 06:03:42 -0700
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

>From Version 2:
  - Removed U64_{HI,LO}; Using {upper,lower}_32_bits instead.
  - Use regular napi weight definition.
  - [We still use the __le variants for variables, since we didn't get
     a reply regarding the change into non-user API types].

>From Version 1:
  - Removed private license file; Instead revised comments at source headers.

Thanks,
Ariel Elior

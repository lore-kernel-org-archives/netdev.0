From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net v2 0/2] qlcnic fixes
Date: Tue, 8 Mar 2016 02:39:56 -0500
Message-ID: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:16991 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753959AbcCHIU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 03:20:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series adds following fixes.

o While processing mailbox if driver gets a spurious mailbox
  interrupt it leads into premature completion of a next
  mailbox request. Added a guard against this by checking current
  state of mailbox and ignored spurious interrupt.
  Added a stats counter to record this condition.

v2:

o Added patch that removes usage of atomic_t as we are not implemeting
  atomicity by using atomic_t value.

Please apply these fixes to net.

Thanks,
Rajesh

Rajesh Borundia (2):
  qlcnic: Remove unnecessary usage of atomic_t
  qlcnic: Fix mailbox completion handling during spurious interrupt

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  3 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 24 ++++++++++++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  3 ++-
 3 files changed, 19 insertions(+), 11 deletions(-)

-- 
1.8.3.1

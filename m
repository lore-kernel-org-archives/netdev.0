From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/6] qed: Management interaction & feature changes
Date: Thu, 23 Mar 2017 15:50:14 +0200
Message-ID: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46970 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751833AbdCWNue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All patches in this series either affect direct interaction with the
management firmware, or changes logic relating to some values retrieved
from it.

Patch #1 revises the basic logic for sending messages to the management
firmware and there completion, and is the most significant [at least
code-wise] of the bunch.

Patch #2 changes infrastrcure in a way that should better protect us form
mistakes leading to stack corruption such as was fixed in
bb4802428432 ("qed: Prevent stack corruption on MFW interaction").

Patch #3 corrects some update API endian issue [sent here as it would
create conflicts with #2, and because it's lack would create a rather
insignifcant problem].

Patch #4 removes some unnecessary logging, allowing cleaner forward
compatibility with future management firmware versions.

Patches #5, #6 slightly change the number of possible L2 queues in some
scenarios, leading to the possibility of having more queues / VFS.

Dave,

Please consider applying this series to 'net-next'.

Thanks,
Yuvsl


Tomer Tayar (2):
  qed: Revise MFW command locking
  qed: Pass src/dst sizes when interacting with MFW

Yuval Mintz (4):
  qed: Correct endian order of MAC passed to MFW
  qed: Reduce verbosity of unimplemented MFW messages
  qed: Don't waste SBs unused by RoCE
  qed: Reserve VF feature before PF

 drivers/net/ethernet/qlogic/qed/qed_dev.c |  38 ++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 525 +++++++++++++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_mcp.h |  17 +-
 3 files changed, 373 insertions(+), 207 deletions(-)

-- 
1.9.3

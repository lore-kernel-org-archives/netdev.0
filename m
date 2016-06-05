From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/6] qed: IOV series - relax firmware requirements
Date: Sun, 5 Jun 2016 13:11:10 +0300
Message-ID: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:22235 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750785AbcFEKLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order for VFs to work, current implementation demands that the VF's
requried storm firmware would be exactly the version that was loaded by
the PF, which is a very harsh requirement.
This patch series is intended to relax this -
the recently submitted firmware is intended to be forward/backward
compatible in its fastpath [slowpath is configured by PF on behalf of VF],
and so VFs would only be required of having the same major faspath HSI in
order to work.

Most of the other patches in this series extend current forward
compatibilty of driver to reduce chance of breaking PF/VF compatibility
in the future. A few are unrelated IOV changes.

Dave,

Please consider applying these to 'net-next'.

Thanks,
Yuval

Yuval Mintz (6):
  qed: Relax VF firmware requirements
  qed: PF-VF resource negotiation
  qed: Make PF more robust against malicious VF
  qed: Move doorbell calculation from VF to PF
  qed: PF enforce MAC limitation of VFs
  qed: PF to reply to unknown messages

 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 488 +++++++++++++++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |   9 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |  95 ++++--
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |  13 +-
 4 files changed, 456 insertions(+), 149 deletions(-)

-- 
1.9.3

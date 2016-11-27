From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 00/11] qed*: Add XDP support
Date: Sun, 27 Nov 2016 16:51:02 +0200
Message-ID: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:47038 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752060AbcK0Ows (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 09:52:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is intended to add XDP to the qede driver, although
it contains quite a bit of cleanups, refactorings and infrastructure
changes as well.

The content of this series can be roughly divided into:

 - Datapath improvements - mostly focused on having the datapath utilize
parameters which can be more tightly contained in cachelines.
Patches #1, #2, #8, #9 belong to this group.

 - Refactoring - done mostly in favour of XDP. Patches #3, #4, #5, #9.

 - Infrastructure changes - done in favour of XDP. Paches #6 and #7 belong
to this category [#7 being by far the biggest patch in the series].

 - Actual XDP support - last two patches [#10, #11].

Hi Dave,

Please consider applying this to `net-next'.
[Probably optimistic for V1 :-P]

Thanks,
Yuval


Yuval Mintz (11):
  qede: Optimize aggregation information size
  qed: Optimize qed_chain datapath usage
  qede: Remove 'num_tc'.
  qede: Refactor statistics gathering
  qede: Refactor data-path Rx flow
  qede: Revise state locking scheme
  qed*: Handle-based L2-queues.
  qede: Don't check netdevice for receive-hashing
  qede: Better utilize the qede_[rt]x_queue
  qede: Add basic XDP support
  qede: Add support for XDP_TX

 drivers/net/ethernet/qlogic/qed/qed.h             |   12 -
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |   33 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  595 +++++----
 drivers/net/ethernet/qlogic/qed/qed_l2.h          |  133 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |    4 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       |  275 ++--
 drivers/net/ethernet/qlogic/qed/qed_sriov.h       |   21 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c          |   90 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h          |   40 +-
 drivers/net/ethernet/qlogic/qede/qede.h           |  163 ++-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c   |  210 +--
 drivers/net/ethernet/qlogic/qede/qede_main.c      | 1409 +++++++++++++--------
 include/linux/qed/qed_chain.h                     |  144 ++-
 include/linux/qed/qed_eth_if.h                    |   56 +-
 14 files changed, 1894 insertions(+), 1291 deletions(-)

-- 
1.9.3

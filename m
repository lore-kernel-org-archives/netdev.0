From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/5] qede: support XDP head adjustments
Date: Fri, 7 Apr 2017 11:04:56 +0300
Message-ID: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ast@fb.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43361 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752775AbdDGIGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:06:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel has brought to my attention the fact that qede is the only driver
that currently supports XDP but still fails any program where
xdp_adjust_head is set on the bpf_prog. This series is meant to remedy
this and align qede with the rest of the driver, making it possible to
remove said field.

Patch #1 contains a minor cache-saving optimization for latter patches.

Patches #2 & #3 address existing issues with the qede implementation
[#2 should have been a part of this as it addresses something that's
affected by the additional headroom; #3 is simply here for the ride].

Patches #4 & #5 add the necessary logic in driver for ingress headroom,
the first adding the infrastrucutre needed for supporting the headroon
[as currently qede doesn't support such], and the second removing the
existing XDP limitation.

Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval

Yuval Mintz (5):
  qede: Update receive statistic once per NAPI
  qede: Correct XDP forward unmapping
  qede: Prevent VFs from using XDP
  qede: Add support for ingress headroom
  qede: Support XDP adjustment of headers

 drivers/net/ethernet/qlogic/qede/qede.h        | 22 +++++---
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 10 ++--
 drivers/net/ethernet/qlogic/qede/qede_fp.c     | 70 +++++++++++++++-----------
 drivers/net/ethernet/qlogic/qede/qede_main.c   | 14 +++---
 4 files changed, 68 insertions(+), 48 deletions(-)

-- 
1.9.3

From: Quentin Monnet <quentin.monnet@6wind.com>
Subject: [PATCH net-next 0/2] act_bpf, cls_bpf: send eBPF bytecode through
Date: Fri, 15 Apr 2016 12:07:34 +0200
Message-ID: <1460714856-7221-1-git-send-email-quentin.monnet@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36845 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbcDOKID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 06:08:03 -0400
Received: by mail-wm0-f43.google.com with SMTP id v188so24056721wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 03:08:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a new BPF traffic control filter or action is set up with tc, the
bytecode is sent back to userspace through a netlink socket for cBPF, but
not for eBPF (the file descriptor pointing to the object file containing
the bytecode is sent instead).

This patch makes cls_bpf and act_bpf modules send the bytecode for eBPF as
well (in addition to the file descriptor).

New BPF flags are used in order to differenciate what BPF version is in
use, so that userspace tools can process the bytecode properly.

Once the series is accepted and merged, it is intended to submit a patch
for the iproute2 package, so as to fix tc utility so as to use the new
flags and to display the bytecode in eBPF format when needed. This tc
patch is already available at:
https://github.com/6WIND/iproute2/commits/netlink_eBPF

Quentin Monnet (2):
  act_bpf: send back eBPF bytecode through netlink socket
  cls_bpf: send back eBPF bytecode through netlink socket

 include/uapi/linux/pkt_cls.h       |  1 +
 include/uapi/linux/tc_act/tc_bpf.h |  1 +
 net/sched/act_bpf.c                | 23 +++++++++++++++++++++++
 net/sched/cls_bpf.c                | 25 +++++++++++++++++++++++--
 4 files changed, 48 insertions(+), 2 deletions(-)

-- 
2.7.4

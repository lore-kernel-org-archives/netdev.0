From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 0/2] bpf: Allow retrieval of ebpf filters
Date: Fri,  3 Feb 2017 12:38:21 -0800
Message-ID: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35419 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752260AbdBCUi3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:38:29 -0500
Received: by mail-pg0-f42.google.com with SMTP id 194so9339406pgd.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 12:38:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mentioned at netconf in October, insight into bpf filters is an
essential part of debugging and verifying a particular networking
configuration. For example, classic bpf filters can be returned for
packet sockets as part of the sock_diag infrastructure and the
PACKET_DIAG_FILTER attribute. This capability is leveraged by
'ss --bpf' to dump the filter when requested.

This series adds similar support to ebpf, starting with filters
attached to a cgroup. The first patch saves the original bpf
instructions in a manner similar to classic bpf. The second patch
allows the retrieval of filters applied to a cgroup.

David Ahern (2):
  bpf: Save original ebpf instructions
  bpf: Add support to retrieve program attached to a cgroup

 include/linux/bpf-cgroup.h |  7 ++++
 include/linux/filter.h     |  5 ++-
 include/uapi/linux/bpf.h   |  9 +++++
 kernel/bpf/cgroup.c        | 31 +++++++++++++++
 kernel/bpf/syscall.c       | 97 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup.c            | 12 ++++++
 6 files changed, 160 insertions(+), 1 deletion(-)

-- 
2.1.4

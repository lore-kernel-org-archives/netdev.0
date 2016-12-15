From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 0/4] ip vrf fixups
Date: Thu, 15 Dec 2016 12:06:58 -0800
Message-ID: <1481832422-10267-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35748 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbcLOUHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 15:07:09 -0500
Received: by mail-pg0-f46.google.com with SMTP id p66so23346392pga.2
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 12:07:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor cleanups to the 'ip vrf' command.

Patch 1 moves the CGROUP_BPF hint to the failure of prog_load since it
fails first.

Patch 2 refactors ipvrf_identify. The action part is moved to a function
that can be used standalone and in the process flipped to fopen/fgets for
robustness should the cgroups file grow larger than 4k.

Patch 3 fixes the path switching to "default" VRF.

Patch 4 moves a task to default VRF when switching namespaces.

David Ahern (4):
  ip vrf: Move kernel config hint to prog_load failure
  ip vrf: Refactor ipvrf_identify
  ip vrf: Fix reset to default VRF
  ip netns: Reset vrf to default VRF on namespace switch

 ip/ip_common.h |   1 +
 ip/ipnetns.c   |   5 +++
 ip/ipvrf.c     | 103 +++++++++++++++++++++++++++++++++++----------------------
 3 files changed, 69 insertions(+), 40 deletions(-)

-- 
2.1.4

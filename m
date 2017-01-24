From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net v3 0/2] net: Fix oops on state free after lwt module unload
Date: Tue, 24 Jan 2017 16:26:46 +0000
Message-ID: <1485275208-31702-1-git-send-email-rshearma@brocade.com>
References: <1484958086-6151-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:51532 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750748AbdAXQ1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:27:41 -0500
In-Reply-To: <1484958086-6151-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An oops is seen in lwtstate_free after an lwt ops module has been
unloaded. This patchset fixes this by preventing modules implementing
lwtunnel ops from being unloaded whilst there's state alive using
those ops. The first patch adds fills in a new owner field in all lwt
ops and the second patch makes use of this to reference count the
modules as state is built and destroyed using them.

Changes in v3:
 - don't put module reference if try_module_get fails on building state

Changes in v2:
 - specify module owner for all modules as suggested by DaveM
 - reference count all modules building lwt state, not just those ops
   implementing destroy_state, as also suggested by DaveM.
 - rebased on top of David Ahern's lwtunnel changes

Robert Shearman (2):
  net: Specify the owning module for lwtunnel ops
  lwtunnel: Fix oops on state free after encap module unload

 include/net/lwtunnel.h    | 2 ++
 net/core/lwt_bpf.c        | 1 +
 net/core/lwtunnel.c       | 6 +++++-
 net/ipv4/ip_tunnel_core.c | 2 ++
 net/ipv6/ila/ila_lwt.c    | 1 +
 net/ipv6/seg6_iptunnel.c  | 1 +
 net/mpls/mpls_iptunnel.c  | 1 +
 7 files changed, 13 insertions(+), 1 deletion(-)

-- 
2.1.4

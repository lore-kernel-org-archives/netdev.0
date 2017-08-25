From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next 0/3] gre: add collect_md mode for ERSPAN tunnel
Date: Fri, 25 Aug 2017 09:21:26 -0700
Message-ID: <1503678089-27131-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34009 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934275AbdHYQVk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 12:21:40 -0400
Received: by mail-pg0-f66.google.com with SMTP id 63so374892pgc.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 09:21:40 -0700 (PDT)
Received: from sc9-mailhost2.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id k197sm1051155pga.78.2017.08.25.09.21.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 09:21:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series provide collect_md mode for ERSPAN tunnel.  The fist patch
refactors the existing gre_fb_xmit function by exacting the route cache
portion into a new function called prepare_fb_xmit.  The second patch
introduces the collect_md mode for ERSPAN tunnel, by calling the
prepare_fb_xmit function and adding ERSPAN specific logic.  The final patch
adds the test case using bpf_skb_{set,get}_tunnel_{key,opt}.

Thank you

William Tu (3):
  gre: refactor the gre_fb_xmit
  gre: add collect_md mode to ERSPAN tunnel
  samples/bpf: extend test_tunnel_bpf.sh with ERSPAN

 include/net/ip_tunnels.h       |   4 +-
 net/ipv4/ip_gre.c              | 157 ++++++++++++++++++++++++++++++++++++-----
 samples/bpf/tcbpf2_kern.c      |  63 ++++++++++++++++-
 samples/bpf/test_tunnel_bpf.sh |  29 ++++++++
 4 files changed, 232 insertions(+), 21 deletions(-)

-- 
2.7.4

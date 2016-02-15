From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 0/6] Namespacify various ip sysctl knobs
Date: Mon, 15 Feb 2016 12:11:26 +0200
Message-ID: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
	pabeni@redhat.com, jmorris@namei.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35225 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbcBOKLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:11:36 -0500
Received: by mail-wm0-f42.google.com with SMTP id c200so105162937wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:11:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending since I forgot to cc linux-netdev]

Hello, 

This series continues namespacifying more net related knobs.
The focus here is on ip options. Patches 1,3,4,5 namespacify
the respective sysctl knobs. Patch 2 moves some igmp code to the 
correct file (and function) and also adds some #ifdef guards to 
silence compilation warnings. 

Finally, patch 5 exposes the ip fragmentation related sysctls 
since all of the knobs are namespaced.

Nikolay Borisov (6):
  ipv4: Namespaceify ip_default_ttl sysctl knob
  igmp: net: Move igmp namespace init to correct file
  ipv4: Namespacify ip_dynaddr sysctl knob
  ipv4: namespacify ip_early_demux sysctl knob
  ipv4: namespacify ip fragment max dist sysctl knob
  net: Export ip fragment sysctl to unprivileged users

 include/net/inet_frag.h                  |  1 +
 include/net/ip.h                         |  6 ----
 include/net/netns/ipv4.h                 |  4 +++
 include/net/route.h                      |  5 ++--
 net/bridge/netfilter/nft_reject_bridge.c |  8 +++--
 net/ipv4/af_inet.c                       | 10 ++-----
 net/ipv4/igmp.c                          | 14 +++++++++
 net/ipv4/ip_fragment.c                   | 29 +++++++++---------
 net/ipv4/ip_input.c                      |  5 +---
 net/ipv4/ip_output.c                     |  3 --
 net/ipv4/ip_sockglue.c                   |  5 +++-
 net/ipv4/netfilter/ipt_SYNPROXY.c        |  3 +-
 net/ipv4/proc.c                          |  2 +-
 net/ipv4/sysctl_net_ipv4.c               | 50 +++++++++++++++++---------------
 net/ipv4/tcp_ipv4.c                      |  6 ----
 net/ipv6/ip6_input.c                     |  2 +-
 16 files changed, 77 insertions(+), 76 deletions(-)

-- 
2.5.0

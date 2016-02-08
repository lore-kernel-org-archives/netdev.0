From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 0/4] Make igmp sysctl knobs namespace aware
Date: Mon,  8 Feb 2016 23:29:20 +0200
Message-ID: <1454966964-13559-1-git-send-email-kernel@kyup.com>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, edumazet@google.com,
	pdowney@brocade.com, dsa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38656 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbcBHV33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 16:29:29 -0500
Received: by mail-wm0-f46.google.com with SMTP id p63so134100148wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 13:29:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series continue making more of the net related sysctls
namespace aware. The first 2 and last patches are straight 
forward and convert sysctls which weren't defined to be 
namespace aware. The only thing in them is that each removes 
a define which is used in only one place (to initialise 
the respective sysctl) so I don't think this is a huge loss. 

The third patch however, converts igmp_llm_reports which was
already defined in the ipv4_net_table but wasn't using any of 
the net namespace infrastructure. 

Nikolay Borisov (4):
  igmp: Namespaceify igmp_max_memberships sysctl knob
  igmp: Namespaceify igmp_max_msf sysctl knob
  igmp: Namespaceify igmp_llm_reports sysctl knob
  igmp: Namespacify igmp_qrv sysctl knob

 include/linux/igmp.h       |  5 ----
 include/net/netns/ipv4.h   |  5 ++++
 net/ipv4/igmp.c            | 64 ++++++++++++++++++++++++----------------------
 net/ipv4/ip_sockglue.c     |  5 ++--
 net/ipv4/sysctl_net_ipv4.c | 50 ++++++++++++++++++------------------
 net/ipv4/tcp_ipv4.c        |  6 +++++
 6 files changed, 73 insertions(+), 62 deletions(-)

-- 
2.5.0

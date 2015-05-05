From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v3 0/2]  Multicast processing in IPvlan
Date: Mon,  4 May 2015 17:05:56 -0700
Message-ID: <1430784356-2049-1-git-send-email-maheshb@google.com>
Cc: Dan Willems <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:33874 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbbEEAID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:08:03 -0400
Received: by iery20 with SMTP id y20so482468ier.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 17:08:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Willems pointed out that autoconf in IPvlan is broken because of the
way broadcast bit gets set. Since broadcast processing is a real performance
drain, the broadcast bit in multicast filter was only set when the interface
was configured with IPv4 address. In autoconf scenario, when there are
no addresses configured; this logic did not work and it wouldn't allow
DHCPv4 to work. The only way was to add protocol specific hacks to avoid
processing unnecessary broadcast burdon.

This jugglery could be avoided if these multicast / broadcast packets are taken
out of fast-path and are processed in a work-queue. This will enable us to add
broadcast bit in all multicast filters without any impact on performance of
the virtual device. This patch series just does that.

Mahesh Bandewar (2):
  ipvlan: Defer multicast / broadcast processing to a work-queue
  ipvlan: Always set broadcast bit in multicast filter

 drivers/net/ipvlan/ipvlan.h      |   5 ++
 drivers/net/ipvlan/ipvlan_core.c | 138 ++++++++++++++++++++++++---------------
 drivers/net/ipvlan/ipvlan_main.c |  25 ++++---
 3 files changed, 102 insertions(+), 66 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c

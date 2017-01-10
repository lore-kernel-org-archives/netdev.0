From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 0/3] add support for IPv6 Segment Routing
Date: Tue, 10 Jan 2017 17:41:23 +0100
Message-ID: <1484066486-22152-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:45788 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764059AbdAJQkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:40:49 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id A248A67D9B5
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:40:34 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the IPv6 Segment Routing implementation in
the Linux kernel. The following features are supported.

* IPv6 SR lightweight tunnels encapsulation ("ip route add ... encap seg6 ...")
* Parsing of routes with a seg6 lwt encap ("ip route show")
* Control of internal SR structures: tunnel source ("ip sr tunsrc") and
  HMAC ("ip sr hmac"). HMAC support enables to map an HMAC Key ID to
  a pair of algorithm + secret.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

David Lebrun (3):
  sr: add header files for SR-IPv6
  ip: add ip sr command to control SR-IPv6 internal structures
  iproute: add support for SR-IPv6 lwtunnel encapsulation

 include/linux/seg6.h          |  54 ++++++++++
 include/linux/seg6_genl.h     |  32 ++++++
 include/linux/seg6_hmac.h     |  21 ++++
 include/linux/seg6_iptunnel.h |  38 +++++++
 ip/Makefile                   |   2 +-
 ip/ip.c                       |   3 +-
 ip/ip_common.h                |   1 +
 ip/iproute.c                  |   6 +-
 ip/iproute_lwtunnel.c         | 160 ++++++++++++++++++++++++++++
 ip/ipseg6.c                   | 238 ++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 551 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/seg6.h
 create mode 100644 include/linux/seg6_genl.h
 create mode 100644 include/linux/seg6_hmac.h
 create mode 100644 include/linux/seg6_iptunnel.h
 create mode 100644 ip/ipseg6.c

-- 
2.7.3

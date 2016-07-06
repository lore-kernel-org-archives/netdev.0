From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 0/4] net: support MPLS in IPv4 and UDP
Date: Wed,  6 Jul 2016 20:22:31 +0200
Message-ID: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35193 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbcGFSWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:22:51 -0400
Received: by mail-wm0-f42.google.com with SMTP id z126so121548463wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:22:51 -0700 (PDT)
Received: from penelope.isobedori.kobe.vergenet.net (dhcp-077-251-078-056.chello.nl. [77.251.78.56])
        by smtp.gmail.com with ESMTPSA id m5sm629757wmm.10.2016.07.06.11.22.48
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Jul 2016 11:22:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This short series provides support for MPLS in IPv4 (RFC4023), and by
virtue of FOU, MPLS in UDP (RFC7510).

The changes are as follows:
1. Teach tunnel4.c about AF_MPLS, it already understands AF_INET and
   AF_INET6
2. Enhance IPIP and SIT to handle MPLS. Both already handle IPv4.
   SIT also already handles IPv6.
3. Trivially enhance MPLS to allow routes over SIT and IPIP tunnels.

A corresponding iproute2 patchset will also be posted.

Simon Horman (4):
  tunnels: support MPLS over IPv4 tunnels
  sit: support MPLS over IPv4
  ipip: support MPLS over IPv4
  mpls: allow routes on ipip and sit devices

 net/ipv4/ipip.c    | 137 ++++++++++++++++++++++++++++++++++++++++++++++-------
 net/ipv4/tunnel4.c |  77 ++++++++++++++++++++++++++----
 net/ipv6/sit.c     |  93 +++++++++++++++++++++++++++++-------
 net/mpls/af_mpls.c |   6 ++-
 4 files changed, 269 insertions(+), 44 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344

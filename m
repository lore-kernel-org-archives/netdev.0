From: Vincent Bernat <bernat@luffy.cx>
Subject: nonlocal_bind and IPv6
Date: Wed, 14 Dec 2011 17:20:46 +0100
Message-ID: <1323879648-419-1-git-send-email-bernat@luffy.cx>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:39845 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755177Ab1LNQVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 11:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a second tentative to port ip_nonlocal_bind to IPv6. The two
patches are independant. The first patch enables
net.ipv6.ip_nonlocal_bind and is "namespace aware". The second patch
modifies net.ipv4.ip_nonlocal_bind to also be "namespace aware". I
don't know if this is something important.

I did not test the SCTP part of the second patch (but it compiles).

 Documentation/networking/ip-sysctl.txt |    5 +++++
 include/net/netns/ipv4.h               |    1 +
 include/net/netns/ipv6.h               |    1 +
 net/ipv4/af_inet.c                     |    6 +-----
 net/ipv4/ping.c                        |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |   16 +++++++++-------
 net/ipv6/af_inet6.c                    |    6 ++++--
 net/ipv6/sysctl_net_ipv6.c             |    8 ++++++++
 net/sctp/protocol.c                    |    2 +-
 9 files changed, 31 insertions(+), 16 deletions(-)

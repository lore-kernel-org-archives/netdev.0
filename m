From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/7] net: ipmr: more cleanups and mfc netlink support
Date: Thu, 26 Nov 2015 15:23:43 +0100
Message-ID: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33639 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbbKZOYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:03 -0500
Received: by wmec201 with SMTP id c201so33568972wme.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This set continues with the minor cleanups in the first 6 patches and
patch 7 adds the first new feature - MFC manipulation via netlink. It
registers NEWROUTE/DELROUTE for that purpose and uses the same semantics
as the already present netlink dump. The only new attribute that is used
is RTA_PREFSRC to denote an MFC_PROXY entry. Currently the table must
exist before adding an entry, and new tables can be created only via
setsockopt, but that will be changed in the future.
This set was tested with modified iproute2 which supports NEWROUTE/DELROUTE
for RTNL_FAMILY_IPMR.

Cheers,
 Nik

Nikolay Aleksandrov (7):
  net: remove unnecessary mroute.h includes
  net: ipmr: remove unused MFC_NOTIFY flag and make the flags enum
  net: ipmr: adjust mroute.h style and drop extern
  net: ipmr: move struct mr_table and VIF_EXISTS to mroute.h
  net: ipmr: move pimsm_enabled to pim.h and rename
  net: ipmr: fix setsockopt error return
  net: ipmr: add mfc newroute/delroute netlink support

 include/linux/mroute.h    |  76 ++++++++++++---------
 include/linux/pim.h       |   5 ++
 net/ipv4/ip_gre.c         |   1 -
 net/ipv4/ip_output.c      |   1 -
 net/ipv4/ip_tunnel.c      |   1 -
 net/ipv4/ip_tunnel_core.c |   1 -
 net/ipv4/ip_vti.c         |   1 -
 net/ipv4/ipip.c           |   1 -
 net/ipv4/ipmr.c           | 168 +++++++++++++++++++++++++++++++++++++---------
 net/ipv6/ip6_gre.c        |   1 -
 10 files changed, 188 insertions(+), 68 deletions(-)

-- 
2.4.3

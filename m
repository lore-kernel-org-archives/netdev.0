From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 0/2] net: vrf: Improve use of FIB rules
Date: Mon,  6 Jun 2016 20:35:50 -0700
Message-ID: <1465270552-30925-1-git-send-email-dsa@cumulusnetworks.com>
References: <[PATCH net-next v4 0/2] net: vrf: Improve use of FIB rules>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34210 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112AbcFGDgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 23:36:04 -0400
Received: by mail-pf0-f171.google.com with SMTP id 62so73186747pfd.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 20:36:04 -0700 (PDT)
In-Reply-To: <[PATCH net-next v4 0/2] net: vrf: Improve use of FIB rules>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, VRFs require 1 oif and 1 iif rule per address family per
VRF. As the number of VRF devices increases it brings scalability
issues with the increasing rule list. All of the VRF rules have the
same format with the exception of the specific table id to direct the
lookup. Since the table id is available from the oif or iif in the
loopup, the VRF rules can be consolidated to a single rule that pulls
the table from the VRF device.

This solution still allows a user to insert their own rules for VRFs,
including rules with additional attributes. Accordingly, it is backwards
compatible with existing setups and allows other policy routing as
desired.

David Ahern (2):
  net: Add l3mdev rule
  net: vrf: Add l3mdev rules on first device create

 drivers/net/vrf.c              | 106 ++++++++++++++++++++++++++++++++++++++++-
 include/net/fib_rules.h        |  24 +++++++++-
 include/net/l3mdev.h           |  12 +++++
 include/uapi/linux/fib_rules.h |   1 +
 net/core/fib_rules.c           |  33 +++++++++++--
 net/ipv4/fib_rules.c           |   6 ++-
 net/ipv6/fib6_rules.c          |   6 ++-
 net/l3mdev/l3mdev.c            |  38 +++++++++++++++
 8 files changed, 214 insertions(+), 12 deletions(-)

-- 
2.1.4

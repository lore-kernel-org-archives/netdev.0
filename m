From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/8] iproute2: MPLS support (now with af_bit_len)
Date: Sun, 15 Mar 2015 14:47:59 -0500
Message-ID: <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
	<87lhiyoxnw.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34534 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbCOTvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:51:44 -0400
In-Reply-To: <87lhiyoxnw.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 15 Mar 2015 14:42:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This set of changes  adds support for nexthops in different
address families, with the new netlink RTA_VIA option.

Support is added for routes that change the destination address (as MPLS
does) with the RTA_NEWDST attribute.

Support for MPLS addresses is added (for multiple labels I
had to make up the syntax I used label/label/label as it fits in
well with addresses that don't have a space in them).

Support for these options is merged into David's net-next kernel
tree, and the meaning of the options is unlikely to change in any
significant way before this code merges upstream.

The documentation has been updated to report that the new options
are present and to report roughly what they do.  This includes
ip --help and the man pages.

Eric W. Biederman (8):
      iproute2: Add a source addres length parameter to rt_addr_n2a
      iproute2: Make the addr argument of ll_addr_n2a const
      iproute2: Add support for printing AF_PACKET addresses
      iproute2: Add address family to/from string helper functions.
      iproute2: misc whitespace cleanup
      iproute2: Add support for  RTA_VIA attributes
      iproute2: Add support for the RTA_NEWDST attribute.
      iproute2: Add basic mpls support to iproute

 Makefile                  |   3 ++
 include/linux/mpls.h      |  34 +++++++++++++++
 include/linux/rtnetlink.h |  10 +++++
 include/rt_names.h        |   2 +-
 include/utils.h           |  22 ++++++++--
 ip/ip.c                   |  20 +++------
 ip/iplink_bond.c          |   1 +
 ip/ipmonitor.c            |   3 ++
 ip/ipmroute.c             |   2 +
 ip/ipprefix.c             |   4 +-
 ip/iproute.c              | 106 ++++++++++++++++++++++++++++++++++++++++------
 ip/iprule.c               |  10 +++--
 ip/iptunnel.c             |   4 +-
 ip/ipxfrm.c               |  17 +++++---
 ip/link_ip6tnl.c          |   2 +
 ip/xfrm_monitor.c         |   8 ++--
 lib/ll_addr.c             |   2 +-
 lib/mpls_ntop.c           |  48 +++++++++++++++++++++
 lib/mpls_pton.c           |  58 +++++++++++++++++++++++++
 lib/utils.c               |  90 +++++++++++++++++++++++++++++++++++----
 man/man8/ip-route.8.in    |  23 +++++++---
 man/man8/ip.8             |   7 ++-
 22 files changed, 410 insertions(+), 66 deletions(-)

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v3 0/2] rtnetlink: new message for stats
Date: Fri, 15 Apr 2016 20:28:11 -0700
Message-ID: <1460777293-39474-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35985 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbcDPD2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 23:28:18 -0400
Received: by mail-pa0-f54.google.com with SMTP id er2so32286935pad.3
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 20:28:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds a new RTM_GETSTATS message to query stats via
netlink from the kernel. RTM_NEWLINK also dumps links stats today, but
RTM_NEWLINK returns a lot more than just stats and is expensive in some
cases when frequent polling for stats from userspace is a common operation.

RTM_GETSTATS is an attempt to provide a light weight netlink message
to explicity query only stats from the kernel. The idea is to also keep
it extensible so that new kinds of stats can be added to it in the future.

Roopa Prabhu (2):
  rtnetlink: add new RTM_GETSTATS to dump link stats
  ipv6: add support for stats via RTM_GETSTATS

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

RFC to v1 (apologies for the delay in sending this version out. busy days):
        - Addressed feedback from Dave
                - removed rtnl_link_stats
                - Added hdr struct if_stats_msg to carry ifindex and
                  filter mask
                - new macro IFLA_STATS_FILTER_BIT(ATTR) for filter mask
        - split the ipv6 patch into a separate patch, need some more eyes on it
        - prefix attributes with IFLA_STATS instead of IFLA_LINK_STATS for
          shorter attribute names

v1 - v2:
        - move IFLA_STATS_INET6 declaration to the inet6 patch
        - get rid of RTM_DELSTATS
        - mark ipv6 patch RFC. It can be used as an example for
          other AF stats like stats

v2 - v3:
        - add required padding to the if_stats_msg structure(suggested by jamal)
        - rename netdev stat attributes with IFLA_STATS_LINK prefix
          so that they are easily distinguishable with global
          stats in the future (after global stats discussion with thomas)
        - get rid of unnecessary copy when getting stats with dev_get_stats
          (suggested by dave)
        

 include/net/rtnetlink.h        |   5 +
 include/uapi/linux/if_link.h   |  19 ++++
 include/uapi/linux/rtnetlink.h |   7 ++
 net/core/rtnetlink.c           | 201 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c            |  77 ++++++++++++++--
 5 files changed, 301 insertions(+), 8 deletions(-)

-- 
1.9.1

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] rtnetlink: new message for stats
Date: Sat, 12 Mar 2016 17:56:24 -0800
Message-ID: <1457834186-45727-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33472 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744AbcCMB4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 20:56:31 -0500
Received: by mail-pf0-f169.google.com with SMTP id 124so110607594pfg.0
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 17:56:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds a new RTM_GETSTATS message to query link stats via
netlink from the kernel. RTM_NEWLINK also dumps stats today, but
RTM_NEWLINK returns a lot more than just stats and is expensive in some
cases when frequent polling for stats from userspace is a common operation.

RTM_GETSTATS is an attempt to provide a light weight netlink message
to explicity query only link stats from the kernel on an interface.
The idea is to also keep it extensible so that new kinds of stats can be
added to it in the future.


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
        - prefix attributes with IFLA_STATS instead of IFLA_LINK_STATS for shorter
          attribute names


 include/net/rtnetlink.h        |   5 +
 include/uapi/linux/if_link.h   |  19 ++++
 include/uapi/linux/rtnetlink.h |   7 ++
 net/core/rtnetlink.c           | 201 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c            |  77 ++++++++++++++--
 5 files changed, 301 insertions(+), 8 deletions(-)

-- 
1.9.1

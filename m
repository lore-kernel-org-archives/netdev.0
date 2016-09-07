From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/2] ip: fix creation flags reported in RTM_NEWROUTE
 events
Date: Wed, 7 Sep 2016 17:18:50 +0200
Message-ID: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Milan Kocian <milon@wq.cz>,
        Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39597 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbcIGPSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 11:18:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netlink messages sent to user-space upon RTM_NEWROUTE events have their
nlmsg_flags field inconsistently set. While the NLM_F_REPLACE and
NLM_F_APPEND bits are correctly handled, NLM_F_CREATE and NLM_F_EXCL
are always 0.

This series sets the NLM_F_CREATE and NLM_F_EXCL bits when applicable,
for IPv4 and IPv6.

Since IPv6 ignores the NLM_F_APPEND flags in requests, this flag isn't
reported in RTM_NEWROUTE IPv6 events. This keeps IPv6 internal
consistency (same flag semantic for user requests and kernel events) at
the cost of bringing different flag interpretation for IPv4 and IPv6.

Guillaume Nault (2):
  ipv4: fix value of ->nlmsg_flags reported in RTM_NEWROUTE events
  ipv6: report NLM_F_CREATE and NLM_F_EXCL flags in RTM_NEWROUTE events

 net/ipv4/fib_trie.c | 10 +++++++---
 net/ipv6/ip6_fib.c  |  6 +++++-
 2 files changed, 12 insertions(+), 4 deletions(-)

-- 
2.9.3

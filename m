From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 0/2] net/sched: cls_flower: Support matching on ND
Date: Thu,  2 Feb 2017 11:37:33 +0100
Message-ID: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:35046 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdBBKho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:37:44 -0500
Received: by mail-wj0-f181.google.com with SMTP id b20so721743wjs.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:37:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow matching on Neighbour Discovery target IP, and source and
destination link-layer addresses for neighbour solicitation and
advertisement messages.

This is achieved by enhancing the flow dissector.

Sample usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ipv6 parent ffff: flower \
	indev eth0 ip_proto icmpv6 type 136 code 0 \
	nd_target 2001:470:7eb3:403:201:8eff:fe22:8fea \
	nd_tll 00:01:8e:22:8f:ea action drop


Dependency:

This series depends on the following patch which is present in net
040587af3122 ("net/sched: cls_flower: Correct matching on ICMPv6 code")

Simon Horman (2):
  flow dissector: ND support
  net/sched: cls_flower: Support matching on ND

 include/net/flow_dissector.h | 14 ++++++++
 include/uapi/linux/pkt_cls.h |  7 ++++
 net/core/flow_dissector.c    | 83 +++++++++++++++++++++++++++++++++++++++++++-
 net/sched/cls_flower.c       | 42 +++++++++++++++++++++-
 4 files changed, 144 insertions(+), 2 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344

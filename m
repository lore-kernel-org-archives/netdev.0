From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v2 0/3] geneve: Add support for Remote Checksum Offload
Date: Thu, 10 Dec 2015 12:34:30 -0800
Message-ID: <1449779673-3701191-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:19611 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753231AbbLJUel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 15:34:41 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tBAKXrdo005996
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 12:34:41 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 1yqg180599-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 12:34:41 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 6f98b0b69f7d11e5bbc50002c99293a0-223fc210 for <netdev@vger.kernel.org>;	Thu,
 10 Dec 2015 12:34:39 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds UDP checksum configuration via netlink and
Remote Checksum Offload for Geneve,

v2:
  - Fix issue of taking sizeof a pointer instead of the actual object
  - Fix type in commi log

Testing (10Gbps mlx4):

Single connection TCP_STREAM in netperf

  - No UDP checksums, no RCO
     4371.9 Mbpos

  - UDP checksums enabled, no RCO
     7263.4 Mbps
   
  - UDP checksums enabled, RCO enabled
     7607.6 Mbps

200 TCP_RR streams

  - No UDP checksums, no RCO
    55.05% CPU utilization
    879284.9 tps
    184/231/742 50/90/99% latencies

  - UDP checksums enabled, no RCO
    55.46% CPU utilization
    901785 tps
    176/222/738 50/90/99% latencies

  - UDP checksums enabled, RCO enabled
    52.36% CPU utilization
    910582 tps
    174/218/706 50/90/99% latencies


Tom Herbert (3):
  rco: Clean up casting errors
  geneve: UDP checksum configuration via netlink
  geneve: Remote Checksum Offload support

 drivers/net/geneve.c         | 249 ++++++++++++++++++++++++++++++++++++++-----
 include/net/checksum.h       |   3 +-
 include/net/geneve.h         |  22 +++-
 include/uapi/linux/if_link.h |   6 ++
 4 files changed, 246 insertions(+), 34 deletions(-)

-- 
2.4.6

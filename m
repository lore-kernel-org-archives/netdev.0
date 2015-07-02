From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/3] gro: Fixes for tunnels and GRO
Date: Thu, 2 Jul 2015 14:04:11 -0700
Message-ID: <1435871054-635096-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49853 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754368AbbGBVEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:04:49 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t62L2QlU012163
	for <netdev@vger.kernel.org>; Thu, 2 Jul 2015 14:04:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vdb7u865e-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:04:49 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 f8ac915a20fd11e5a54424be0593f280-45cdc2b0 for <netdev@vger.kernel.org>;	Thu,
 02 Jul 2015 14:04:47 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses some issue related to tunneling and GRO:

- Ensure headers are pull into skb->head when putting 1st packet onto
  GRO list
- Fix remote checksum offload to properly deal with frag0 in GRO.
- Add support for GRO at VXLAN tunnel (call gro_cells)

Testing: Ran one netperf TCP_STREAM to highlight impact of different
configurations:

GUE
  Zero UDP checksum
    4628.42 MBps
  UDP checksums enabled
    6800.51 MBps
  UDP checksums and remote checksum offload
    7663.82 MBps
  UDP checksums and remote checksum offload using no-partial
    7287.25 MBps

VXLAN
  Zero UDP checksum
    4112.02
  UDP checksums enabled
    6785.80 MBps
  UDP checksums and remote checksum offload
    7075.56 MBps
    

Tom Herbert (3):
  gro: Pull headers into skb head for 1st skb in gro list
  gro: Fix remcsum offload to deal with frags in GRO
  vxlan: GRO support at tunnel layer

 drivers/net/vxlan.c       | 31 +++++++++++++++----------------
 include/linux/netdevice.h | 44 ++++++++++++++++++++++++++++++++------------
 net/core/dev.c            |  4 ++++
 net/ipv4/fou.c            | 25 +++++++++----------------
 4 files changed, 60 insertions(+), 44 deletions(-)

-- 
1.8.1

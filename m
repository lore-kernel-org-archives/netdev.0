From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/5] ip6: Transmit tunneling fixes
Date: Mon, 9 May 2016 17:12:07 -0700
Message-ID: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58605 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754003AbcEJAMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:12:20 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4A0Bp2R014077
	for <netdev@vger.kernel.org>; Mon, 9 May 2016 17:12:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22u4gm039q-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:12:19 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 db9d62a6164311e697280002c99331b0-705f6c50 for <netdev@vger.kernel.org>;	Mon,
 09 May 2016 17:12:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several fixes suggested by Alexander.

Tested: Running netperf TCP_STREAM with gretap and keyid configured.
Visually verified that MTU is correctly being set. Did not test HW
offload (Alexander plese try)


Tom Herbert (5):
  ip6_gre: Fix MTU setting
  gre6: Fix flag translations
  ip6_gre: Set inner protocol correctly in __gre6_xmit
  ip6: Don't set transport header in IPv6 tunneling
  ip6_gre: Use correct flags for reading TUNNEL_SEQ

 net/ipv6/ip6_gre.c    | 55 ++++++++++++++++++++++++++-------------------------
 net/ipv6/ip6_tunnel.c |  2 --
 2 files changed, 28 insertions(+), 29 deletions(-)

-- 
2.8.0.rc2

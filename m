From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 0/2] tcp: add NV congestion control
Date: Fri, 3 Jun 2016 13:37:56 -0700
Message-ID: <1464986278-2096156-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:63107 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932903AbcFCUiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 16:38:14 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u53KZu0h028597
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 13:38:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 23apaqxvd4-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 13:38:13 -0700
Received: from facebook.com (2401:db00:11:d037:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 16d1cc7829cb11e6aa200002c9521c9e-dee52e0 for <netdev@vger.kernel.org>;	Fri,
 03 Jun 2016 13:38:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This version of NV does much better than previous versions when things are
very congested and also adds a couple of experimental features.

Tested in a rack using between 1 and 380 active TCP-NV flows.

Consists of the following patches:
[PATCH net-next 1/2] tcp: add in_flight to tcp_skb_cb
[PATCH net-next 2/2] tcp: add NV congestion control

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

include/net/tcp.h     |   2 +
net/ipv4/Kconfig      |  16 ++
net/ipv4/Makefile     |   1 +
net/ipv4/tcp_input.c  |   5 +-
net/ipv4/tcp_nv.c     | 597 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
net/ipv4/tcp_output.c |   4 +-
6 files changed, 623 insertions(+), 2 deletions(-)

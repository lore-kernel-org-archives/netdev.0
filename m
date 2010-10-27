From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH 0/5] tcp: ipv4 listen state scaling
Date: Wed, 27 Oct 2010 17:23:24 +0400
Message-ID: <AANLkTikmNCogLY3ZVhtfxOnSpWdPMq1YBCM3ZprkxEsP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Shan Wei <shanwei@cn.fujitsu.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42717 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758164Ab0J0NX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*Note: this patch depends on "[PATCH] tcp: md5 signature check scaling"*
Hi.

The problem with current TCP stack implementation is that it locks
socket in tcp_v4_rcv on each incoming packet. However, incoming SYNs
may be processed in parallel with syncookies. And it helps a lot under
synflood. This proposed patch serie fixes this problem, but (as for
now) for ipv4 only.
6-core Xeon with 6 RX queues on NIC:
without patch: 530k syn-pkts/s;
with patch: 1620k syn-pkts/s.

Discussion?

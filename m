From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next v2 0/2] minor tail loss probe improvements
Date: Wed, 12 Aug 2015 11:18:17 -0700
Message-ID: <1439403499-24774-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35222 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbHLSUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 14:20:15 -0400
Received: by pdrg1 with SMTP id g1so9889986pdr.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 11:20:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enhance the tail loss probe (TLP) on some error
conditions. When TLP fails to send a probe, it will no longer
extend the RTO. When it fails to send a new packet because of
receiver window limit, it'll try to retransmit the last packet.

Yuchung Cheng (2):
  tcp: don't extend RTO on failed loss probe attempts
  tcp: TLP retransmits last if failed to send new packet

 net/ipv4/tcp_output.c | 41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

-- 
2.5.0.276.gf5e568e

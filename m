From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 0/2 net-next] tcp: reducing lost retransmits in recovery
Date: Wed,  1 Jul 2015 14:11:13 -0700
Message-ID: <1435785075-20600-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36161 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbbGAVLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 17:11:23 -0400
Received: by igrv9 with SMTP id v9so83260050igr.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 14:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series reduces lost retransmits in recovery, in particular
when dealing with traffic policers. The main problem is that
slow start in recovery under policing can cause massive lost and
retransmit storms: any excess sending rate turns into drops. The
solution is to avoid doing slow start when lost retransmit is
detected and use packet conservation instead.

On networks with traffic policers the patches have lowered the
TCP loss rates by ~20% from Google servers without latency regressions.

Yuchung Cheng (2):
  tcp: reduce cwnd if retransmit is lost in CA_Loss
  tcp: PRR uses CRB mode by default and SS mode conditionally

 net/ipv4/tcp_input.c | 43 +++++++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 20 deletions(-)

-- 
2.4.3.573.g4eafbef

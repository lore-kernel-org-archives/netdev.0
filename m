From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2 1/2] tc_core: Use double in tc_core_time2tick()
Date: Tue, 9 Jun 2009 08:05:26 +0000
Message-ID: <20090609080526.GC5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:33173 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758906AbZFIIF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:05:29 -0400
Received: by mail-ew0-f210.google.com with SMTP id 6so4929033ewy.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 01:05:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CBQ minidle parameter is provided in microseconds, so needs time2tick
conversion.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 tc/q_cbq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index c99dc3b..7f2bd0c 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -406,7 +406,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 		lss.change |= TCF_CBQ_LSS_EWMA|TCF_CBQ_LSS_AVPKT;
 	}
 	if (lss.change&TCF_CBQ_LSS_MINIDLE) {
-		lss.minidle <<= lss.ewma_log;
+		lss.minidle = tc_core_time2tick(lss.minidle << lss.ewma_log);
 		lss.change |= TCF_CBQ_LSS_EWMA;
 	}
 

From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2 2/2 resend] q_cbq: Fix minidle parameter conversion
Date: Tue, 9 Jun 2009 08:16:57 +0000
Message-ID: <20090609081657.GA5556@ff.dom.local>
References: <20090609080526.GC5237@ff.dom.local>
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
Received: from mail-ew0-f210.google.com ([209.85.219.210]:64247 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755864AbZFIIRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:17:02 -0400
Received: by ewy6 with SMTP id 6so4938087ewy.37
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 01:17:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090609080526.GC5237@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09-06-2009 10:05, Jarek Poplawski wrote:
> CBQ minidle parameter is provided in microseconds, so needs time2tick
> conversion.

Wrong subject, sorry,
Jarek P.
---------------------> take 2 / resend

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
 

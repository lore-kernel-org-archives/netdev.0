From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2 v2] Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 07:01:34 +0000
Message-ID: <20090518070134.GB6006@ff.dom.local>
References: <20090517201528.GA8552@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:28093 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616AbZERHBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 03:01:39 -0400
Received: by fg-out-1718.google.com with SMTP id d23so549004fga.17
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 00:01:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090517201528.GA8552@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----------> (One misspelling fixed.)
Return non-zero tc_calc_xmittime() for rate tables

While looking at the problem of HTB accuracy for high speed (~500Mbit
rates) I've found that rate tables have cells filled with zeros for
the smallest sizes. It means such packets aren't accounted at all.
Apart from the correctness of such configs, let's make it safe with
rather overaccounting than leaving it unlimited.

Reported-by: Antonio Almeida <vexwek@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 tc/tc_core.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9a0ff39..14f25bc 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -58,7 +58,9 @@ unsigned tc_core_ktime2time(unsigned ktime)
 
 unsigned tc_calc_xmittime(unsigned rate, unsigned size)
 {
-	return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
+	unsigned t;
+	t = tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
+	return t ? : 1;
 }
 
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)

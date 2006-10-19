From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling for	ATM/ADSL
 (kernel)
Date: Thu, 19 Oct 2006 16:38:27 +0200
Message-ID: <45378DE3.8080700@trash.net>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube> <1161090444.5555.13.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:27340 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1946094AbWJSOim
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 10:38:42 -0400
To: hadi@cyberus.ca
In-Reply-To: <1161090444.5555.13.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> ACKed-by: Jamal Hadi Salim
> 
> When Patrick has his patch ready after this goes in we can revisit.

NACK.

I still think this patch shouldn't go in. There's no point in doing the
same thing twice, and I haven't heard a compelling argument why it has
to be done in a way that only helps qdiscs using rtabs while ignoring
statistics and estimators (I even provided a patch to show how to do
it without these limitations).

Besides that:

+static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, int pktlen)
+{
+	int slot = pktlen + rtab->rate.cell_align;
+	if (slot < 0)
+	  	slot = 0;

Why would it go negative? A negative cell_align doesn't make sense I
guess.

+	slot >>= rtab->rate.cell_log;
+	if (slot > 255)
+		return rtab->data[255] + 1;

Whats the point of this? Is it just to keep htb giant statistics
working?


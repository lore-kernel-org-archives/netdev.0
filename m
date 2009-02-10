From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2 net-next] Re: can't add tc multiq
Date: Tue, 10 Feb 2009 07:41:54 +0000
Message-ID: <20090210074154.GA4190@ff.dom.local>
References: <20090209081553.4a874433@extreme> <20090209214446.GA2542@ami.dom.local> <20090209144052.6636f069@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:49137 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZBJHmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 02:42:00 -0500
Received: by fg-out-1718.google.com with SMTP id 16so1234097fgg.17
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 23:41:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090209144052.6636f069@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 02:40:52PM -0800, Stephen Hemminger wrote:
...
> Rather than warning which will buried off on some console that user will never
> see (and can cause DoS overload). A better errno should be chosen.

I think admins are used to reading console messages, but we can try
with a better errno too.

Thanks,
Jarek P.
-------------------> take 2

pkt_sched: sch_multiq: Change errno on non-multiqueue devices use.

Current "RTNETLINK answers: Invalid argument" warning, while trying to
add multiq qdisc to non-multiqueue device, isn't very helpful and some
of these devs can be changed btw., so let's use a better errno.

With feedback from Stephen Hemminger <shemminger@vyatta.com>

Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_multiq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 7e15186..9127312 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -202,7 +202,7 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 	int i;
 
 	if (!netif_is_multiqueue(qdisc_dev(sch)))
-		return -EINVAL;
+		return -EOPNOTSUPP;
 	if (nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
 

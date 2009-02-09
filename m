From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] Re: can't add tc multiq
Date: Mon, 9 Feb 2009 22:44:47 +0100
Message-ID: <20090209214446.GA2542@ami.dom.local>
References: <20090209081553.4a874433@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:56889 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbZBIVox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 16:44:53 -0500
Received: by bwz5 with SMTP id 5so1918954bwz.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 13:44:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090209081553.4a874433@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, On 02/09/2009 05:15 PM:

> On Mon, 09 Feb 2009 11:43:26 +0300
> Badalian Vyacheslav <slavon@bigtelecom.ru> wrote:
> 
>> Hello all!
>> kernel 2.6.28.4
>> iproute2 - last git
>> Can't use multiq qdisc. How to fix this?
>> Thanks!
>>
>> slavon ~ # tc qdisc add dev eth0 root handle 1: multiq
>> RTNETLINK answers: Invalid argument
...
> You need hardware with multiple transmit queues. Neither e1000 or r8169
> has this.
------------------->
pkt_sched: sch_multiq: Warn on non-multiqueue devices.

Current "RTNETLINK answers: Invalid argument" warning, while trying to
add multiq qdisc to non-multiqueue device, isn't very helpful and some
of these devs can be changed btw., so let's add a small printk.

With feedback from Stephen Hemminger <shemminger@vyatta.com>

Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_multiq.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 7e15186..a38f0c1 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -201,8 +201,11 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 	struct tc_multiq_qopt *qopt;
 	int i;
 
-	if (!netif_is_multiqueue(qdisc_dev(sch)))
+	if (!netif_is_multiqueue(qdisc_dev(sch))) {
+		printk(KERN_WARNING "multiq: dev %s isn't multiqueue.\n",
+		       qdisc_dev(sch)->name);
 		return -EINVAL;
+	}
 	if (nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
 

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 18 Jun 2007 22:54:41 +0200
Message-ID: <4676F111.4000105@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329030D59A7@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42274 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765001AbXFRUyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:54:44 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329030D59A7@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>>+	band = TC_H_MIN(band) - 1;
>>>+	if (band > q->bands) {
>>
>>You copied an off-by-one from an old sch_prio version here.
> 
> 
> Hmm.  This is the sch_prio from the first 2.6.23-dev tree.  I'll resync
> and make sure it's the correct one.

Current 2.6.22-rc and net-2.6.23 have

        if (band >= q->bands)



>>>+static int rr_tune(struct Qdisc *sch, struct rtattr *opt)
>>>+{
>>>+	struct rr_sched_data *q = qdisc_priv(sch);
>>>+	struct tc_rr_qopt *qopt = RTA_DATA(opt);
>>
>>
>>Nested attributes please, don't repeat sch_prio's mistake.
> 
> 
> I'm not sure I understand what you mean here about nested attributes.


Nested netlink attributes, like most qdisc use, instead of
struct tc_rr_qopt (or additionally). The way you've done
it makes it hard to add further attributes later.

BTw, couldn't you just merge sch_rr with prio? AFAICT you
only need a new dequeue function, a new struct Qdisc_ops
and a MODULE_ALIAS.


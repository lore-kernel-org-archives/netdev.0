From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 18:46:22 +0200
Message-ID: <4683E5DE.7000805@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0368@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54814 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760123AbXF1QrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:47:18 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031F0368@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>PJ Waskiewicz wrote:
>>
>>
>>>+
>>> static int __init prio_module_init(void)  {
>>>-	return register_qdisc(&prio_qdisc_ops);
>>>+	int err;
>>>+	err = register_qdisc(&prio_qdisc_ops);
>>>+	if (!err)
>>>+		err = register_qdisc(&rr_qdisc_ops);
>>>+	return err;
>>> }
>>> 
>>
>>Thats still broken. I'll fix this and some minor cleanness 
>>issues myself so you don't have to go through another resend.
> 
> 
> Auke and I just looked at register_qdisc() and this code.  Maybe we
> haven't had enough coffee yet, but register_qdisc() returns 0 on
> success.  So if register_qdisc(&prio_qdisc_ops) succeeds, then
> rr_qdisc_ops gets registered.  I'm curious what is broken with this.

Its not error handling. You do:

err = register qdisc 1
if (err)
	return err;
err = register qdisc 2
if (err)
	unregister qdisc 2
return err

anyways, I already fixed that and cleaned up prio_classify the
way I suggested. Will send shortly.


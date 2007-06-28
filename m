From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 09:43:07 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0368@orsmsx414.amr.corp.intel.com>
References: <4683E363.6020607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5171 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764972AbXF1QnK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:43:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4683E363.6020607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> 
> > +
> >  static int __init prio_module_init(void)  {
> > -	return register_qdisc(&prio_qdisc_ops);
> > +	int err;
> > +	err = register_qdisc(&prio_qdisc_ops);
> > +	if (!err)
> > +		err = register_qdisc(&rr_qdisc_ops);
> > +	return err;
> >  }
> >  
> 
> Thats still broken. I'll fix this and some minor cleanness 
> issues myself so you don't have to go through another resend.

Auke and I just looked at register_qdisc() and this code.  Maybe we
haven't had enough coffee yet, but register_qdisc() returns 0 on
success.  So if register_qdisc(&prio_qdisc_ops) succeeds, then
rr_qdisc_ops gets registered.  I'm curious what is broken with this.

Thanks Patrick
-PJ Waskiewicz

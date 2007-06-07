From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Thu, 7 Jun 2007 15:55:50 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902FFC730@orsmsx414.amr.corp.intel.com>
References: <20070607.154421.109060486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <jeff@garzik.org>,
	<kaber@trash.net>, <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51723 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966123AbXFGWzx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:55:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070607.154421.109060486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I empathize but take a closer look; seems mostly useless.
> 
> I thought E1000 still uses LLTX, and if so then multiple cpus 
> can most definitely get into the ->hard_start_xmit() in parallel.

Not with how the qdisc status protects it today:

include/net/pkt_sched.h:

static inline void qdisc_run(struct net_device *dev)
{
        if (!netif_queue_stopped(dev) &&
            !test_and_set_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
                __qdisc_run(dev);
}

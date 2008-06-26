From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] igb: completely disable interrupts during netpoll
Date: Thu, 26 Jun 2008 00:23:59 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52057B3FE5@orsmsx418.amr.corp.intel.com>
References: <20080625141511.GH22981@gospo.rdu.redhat.com> <20080625.152751.154176346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5236 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbYFZHYV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 03:24:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080625.152751.154176346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> It's better to have a good understanding of why the deadlocks
> happen, and this was decidedly missing from your commit message.
> 
> NAPI is designed in such a way that if pending interrupts arrive
> after NAPI disables chip interrupts it should be handled just
> fine and in fact I see this happen all the time on some of my
> test systems.

I think the deadlocks occur (only when using netpoll) because the tx
cleanup (igb_clean_tx_irq) is being called simultaneously from two
routines, which generally is guaranteed not to happen in regular
everyday napi mode because of the bh_disable before calling dev->poll.



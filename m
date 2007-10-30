From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic removing devices from a teql queuing discipline
Date: Tue, 30 Oct 2007 01:33:41 -0700 (PDT)
Message-ID: <20071030.013341.205362893.davem@davemloft.net>
References: <47261FA1.10300@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751616AbXJ3Id7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 04:33:59 -0400
In-Reply-To: <47261FA1.10300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Mon, 29 Oct 2007 14:00:01 -0400

> The panic is in __teql_resolve (which has been inlined into teql_master_xmit) in
> net/sched/sch_teql.c at this line:
> 
> 	if (n && n->tbl == mn->tbl &&
> 
> Specifically the dereference of n->tbl is faulting as n is not valid.
> 
> And the address looks like part of an ASCCI string...  "figt"

I studied sch_teql.c a bit and I suspect that the slave list
management in teql_destroy() and teql_qdisc_init() might be
suspect.

If someone can take a closer look at this, I'd appreciate it.

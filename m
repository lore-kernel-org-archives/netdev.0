From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: kernel panic removing devices from a teql queuing discipline
Date: Mon, 5 Nov 2007 23:08:00 +0300
Message-ID: <20071105200800.GA4075@2ka.mipt.ru>
References: <47261FA1.10300@redhat.com> <20071030.013341.205362893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54153 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbXKEUHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 15:07:46 -0500
Content-Disposition: inline
In-Reply-To: <20071030.013341.205362893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 01:33:41AM -0700, David Miller (davem@davemloft.net) wrote:
> > The panic is in __teql_resolve (which has been inlined into teql_master_xmit) in
> > net/sched/sch_teql.c at this line:
> > 
> > 	if (n && n->tbl == mn->tbl &&
> > 
> > Specifically the dereference of n->tbl is faulting as n is not valid.

n is never valid (null), mn is garbage.

> > And the address looks like part of an ASCCI string...  "figt"
> 
> I studied sch_teql.c a bit and I suspect that the slave list
> management in teql_destroy() and teql_qdisc_init() might be
> suspect.

tecl_reset() is called from deactivate and qdisc is set to noop already,
but subsequent teql_xmit does not know about it and dereference private
data as teql qdisc and thus oopses. I will fix it tomorrow if you will
not catch it first :)

-- 
	Evgeniy Polyakov

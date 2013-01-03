From: Julia Lawall <julia.lawall@lip6.fr>
Subject: clk dereference in drivers/net/ethernet/ti/cpts.c
Date: Thu, 3 Jan 2013 11:20:52 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1301031040320.1989@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, richardcochran@gmail.com, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:11151 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134Ab3ACKUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 05:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been a discussion recently about how the result of get_clk
should be an opaque handle, not a value that can be dereferenced:

https://lkml.org/lkml/2012/12/20/105

There is such a dereference in drivers/net/ethernet/ti/cpts.c, in the
function cpts_clk_init:

cpts->freq = cpts->refclk->recalc(cpts->refclk);

It was not obvious to me, however, what API function should be used
instead, so I am just reporting the (potential) problem.

thanks,
julia

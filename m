From: Thomas Graf <tgraf@suug.ch>
Subject: Re: pkt_sched: Control group classifier
Date: Thu, 30 Oct 2008 11:54:31 +0100
Message-ID: <20081030105431.GI20815@postel.suug.ch>
References: <20081027.123056.22851224.davem@davemloft.net> <20081027.170524.124746723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50076 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842AbYJ3KyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 06:54:11 -0400
Content-Disposition: inline
In-Reply-To: <20081027.170524.124746723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> 2008-10-27 17:05
> Sorry I had to revert this:
> 
> 1) It can't work as a tristate option, the control group subsystem
>    framework doesn't work with modular enables.

Right, I'll fix this. Thank you.

> 2) There was still a discussion going on about the hardirq/softirq
>    tracing bits.  They seem unnecessary.

I don't see how looking at the number of nested bh disable calls can
be used to reliably determine if a code segment is run in softirq. The
method fails if a dev_queue_xmit() caller running in softirq context
doesn't disable bh explicitly but instead relies on the fact that bh
must already have been disabled as per bh context definition.

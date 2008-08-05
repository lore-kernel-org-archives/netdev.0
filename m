From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 respin] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Mon, 04 Aug 2008 23:31:22 -0700 (PDT)
Message-ID: <20080804.233122.132106854.davem@davemloft.net>
References: <20080804085734.GB12927@ff.dom.local>
	<20080804.231449.199557608.davem@davemloft.net>
	<20080805063423.GA4407@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752206AbYHEGbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 02:31:22 -0400
In-Reply-To: <20080805063423.GA4407@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 5 Aug 2008 06:34:23 +0000

> NAK! You're not allowed to remove such a great comment!
> 
> BTW, I hope you've checked this enough, becouse I've some doubts
> here: this NET_XMIT_BYPASS looks wrong here but maybe it was meant
> to be some NET_RX_ code, like NET_RX_CN_HIGH?

I think it was trying to handle the cases where the
input packet called dev_queue_xmit() and that return
value funnelled back into dst_input().

But that couldn't happen, and even if it could dev_queue_xmit()
always "fixed up" NET_XMIT_BYPASS so that callers never saw it.

Really, this code was totally useless as far as I can tell.

From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Tue, 24 Jul 2012 02:11:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207240157120.2404@ja.ssi.bg>
References: <20120723.140737.822125500680433996.davem@davemloft.net> <20120723.152220.822947775372843073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43974 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab2GWXEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 19:04:05 -0400
In-Reply-To: <20120723.152220.822947775372843073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 23 Jul 2012, David Miller wrote:

> From: David Miller <davem@davemloft.net>
> Date: Mon, 23 Jul 2012 14:07:37 -0700 (PDT)
> 
> > On input packet processing, rt->rt_iif will be zero if we should
> > use skb->dev->ifindex.
> > 
> > Since we access rt->rt_iif consistently via inet_iif(), that is
> > the only spot whose interpretation have to adjust.
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Julian, as you seem to have feared, this turns out to not work.
> 
> We zap the skb->dev apparently, so I'll need to come up with
> a different scheme to handle this.

	I was just replying that I don't see any problems
with the 4 patches but when you say it, may be the net/sched
code will work with output device on forwarding, not input.
Is skb_iif a good source? From include/linux/skbuff.h:

skb_iif: ifindex of device we arrived on

	If it has hidden semantic may be we can make this
comment more specific, does it survive some loops?

	Anyways, the idea for new encoding of rt_iif is very good.

Regards

--
Julian Anastasov <ja@ssi.bg>

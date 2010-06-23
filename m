From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netfilter: allow nf_tproxy_core module to
 be removed
Date: Wed, 23 Jun 2010 11:55:58 -0700 (PDT)
Message-ID: <20100623.115558.189705237.davem@davemloft.net>
References: <20100623183503.GE2687@psychotron.bos.redhat.com>
	<20100623184611.GG27132@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, kaber@trash.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751423Ab0FWSzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 14:55:46 -0400
In-Reply-To: <20100623184611.GG27132@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 23 Jun 2010 20:46:11 +0200

> tproxy assigns skb->destructor, what prevents module unload while such skbs may
> still be around?

The only reference to nf_tproxy_core.ko is for the symbol, "nf_tproxy_assign_sock".
xt_TPROXY.c, which references this symbol, thus creates a symbol dependency on this
module, so xt_TPROXY.o needs to unload before nf_tproxy_core.ko can unload, and
xt_TPROXY.o has it's own manner for handling module references properly.

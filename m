From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Tue, 4 Dec 2012 00:52:16 +0100
Message-ID: <20121203235216.GA11723@1984>
References: <20121130.122243.710720011890818822.davem@davemloft.net>
 <1354538763-2678-1-git-send-email-dries.dewinter@gmail.com>
 <20121203.141128.206409637987621093.davem@davemloft.net>
 <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
 <alpine.LNX.2.01.1212040037240.2816@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dries De Winter <dries.dewinter@gmail.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58851 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327Ab2LCXwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 18:52:25 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1212040037240.2816@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2012 at 12:38:25AM +0100, Jan Engelhardt wrote:
> 
> On Monday 2012-12-03 22:31, Dries De Winter wrote:
> >
> >Not fixing this means that skb->mark is unavailable for use on ICMPv6
> >packets because it will inevitably put those packets on the wrong
> >interface. [...]
> >
> >I use skb->mark for QoS, not for routing so I don't expect
> >the outgoing interface to be affected by my markers.
> 
> Why would it do that, if one has no routes joined to a fwmark NNN
> routing rule?

iptables_mangle assumes that ip_route_me_harder needs to be called if
the mark has changed.

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Mon, 23 Dec 2013 13:13:37 +0100
Message-ID: <20131223121337.GA5373@localhost>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com>
 <20131217130555.GA8874@localhost>
 <52B26841.40800@windriver.com>
 <20131220090419.GA5661@localhost>
 <52B40C01.7070406@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, steffen.klassert@secunet.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54250 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab3LWMNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 07:13:43 -0500
Content-Disposition: inline
In-Reply-To: <52B40C01.7070406@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Dec 20, 2013 at 05:21:05PM +0800, Fan Du wrote:
[...]
> >AH is not the last header, so we still have to use ipv6_find_hdr() to
> >find the good header instead of par->thoff. Note that the ip6_tables
> >sets par->thoff to the last IPv6 extension header.
> 
> I'm quite new to the internal of netfiler, especially about this part.
> I will take a look at the code later.
> 
> >This rises some concerns regarding your ipcomp, I think that if you
> >use this with ah and esp, the ordering of the headers is
> >ah+ipcomp+esp, right?
> 
> This depends on the user land configuration of encapsulation order.
> It can be one of the three types only(ah, esp, ipcomp), the most commonly
> used is ah(outer)+esp(inner).
> 
> I barely see ipcomp used in production, but I remember RFC says ipcomp
> should be done first before esp, because after encryption in esp, the data
> is polluted, i.e., not suitable for compressed anymore(I'm not sure the
> details theory behind this statement.)

In that case we have to use ipv6_find_hdr(..., IPPROTO_IPCOMP, ...),
since par->thoff will point to the last header which is esp. After
this change, the ipcomp ipv6 match will look very similar to what you
have in ah_mt6(...) in net/ipv6/netfilter/ip6t_ah.c. Please, rework
that in your ipcomp match patch and resend. Thanks.

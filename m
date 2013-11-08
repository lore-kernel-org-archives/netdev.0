From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Fri, 8 Nov 2013 12:01:01 +0100
Message-ID: <20131108110101.GR31491@secunet.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
 <20131107112549.GP31491@secunet.com>
 <527B8DC5.6080702@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37426 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab3KHLBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 06:01:05 -0500
Content-Disposition: inline
In-Reply-To: <527B8DC5.6080702@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 01:55:33PM +0100, Christophe Gouault wrote:
> Hello Steffen,
> 
> I am also interested in knowing Saurabh's intentions regarding the
> behavior of policies bound to vti interfaces.
> 
> However, please note that setting a policy with a wildcard selector
> works in both cases (before or after this patch), so a common test
> case can be defined.

Yes, I looked at the Cisco vti documents but all examples I found use
wildcard selectors which work for both. So I'm still not sure which
version is the right one. Let's wait on Saurabh's explaination.

> 
> Actually the *previous* patch on vti (7263a5187f9e vti: get rid of
> nf mark rule in prerouting) introduced significant changes, and
> implies behaviors dependant on the kernel version, but it seemed to
> meet Saurabh's agreement, as the following thread witnesses:
> 
> http://www.spinics.net/lists/netdev/msg253134.html

I've just noticed that this went to the stable trees. People who
update a stable kernel want (security) fixes in the first place,
they don't want to change their configuration on the IPsec gateways.
So I think patches that require a configuration change should better
go to net-next, unless it's a urgent fix.

I was not on Cc and it looks like I've overlooked this on the list.
The vti interfaces are pure IPsec interfaces, so perhaps we should
add them to the IPsec section in the maintainers file (maybe together
with the main IPsec protocols esp, ah and ipcomp, which are also not
listed there).

David, would you agree with such a patch?

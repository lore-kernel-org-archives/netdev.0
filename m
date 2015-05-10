From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Sun, 10 May 2015 19:05:50 +0200
Message-ID: <20150510170550.GA4442@salvia>
References: <cover.1431203900.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40647 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479AbbEJRBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 13:01:10 -0400
Content-Disposition: inline
In-Reply-To: <cover.1431203900.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 09, 2015 at 10:51:30PM +0200, Daniel Borkmann wrote:
> These are a couple of cleanups to make ingress a bit more lightweight.

This is plain wrong at many levels.

You're persisting on embedding the ingress code into the core, and you
have to remember that most users don't need this. Modules allows
people to get the code that they need into the core, with this
approach, they have no other choice other than disable from .config
this if they don't need it.

This has to be done the other way around. I just sent a patchset to
clean up this that in exactly the other direction, as a result,
performance is improved for users that don't need this.

We should do things to make users aware that when they request
features, they have to pay a performance cost, and that happens by
when you invoke:

        tc qdisc add dev eth0 handle ffff: ingress

David already stated before that ingress path is performance critical,
but you insist on trying to get qdisc ingress faster *at any cost*.

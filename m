From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] netfilter: take care of timewait sockets
Date: Mon, 3 Sep 2012 09:47:18 +0200
Message-ID: <20120903074718.GA14750@breakpoint.cc>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
 <20120902132834.GB7456@breakpoint.cc>
 <1346626385.2563.44.camel@edumazet-glaptop>
 <1346629684.2563.78.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Sami Farin <hvtaifwkbgefbaei@gmail.com>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47825 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755206Ab2ICHrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 03:47:20 -0400
Content-Disposition: inline
In-Reply-To: <1346629684.2563.78.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Sami Farin reported crashes in xt_LOG because it assumes skb->sk is a
> full blown socket.
> 
> But with TCP early demux, we can have skb->sk pointing to a timewait
> socket.
> 
> Same fix is needed in netfnetlink_log

Looks good, but IMHO it is very un-intuitive that
skb->sk might be a pointer to an object that is not struct sock (or
a compatible object).

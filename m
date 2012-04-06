From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Fri, 06 Apr 2012 03:59:24 +0200
Message-ID: <1333677564.18626.608.camel@edumazet-glaptop>
References: <1333488689.18626.331.camel@edumazet-glaptop>
	 <20120403.173614.962252876842659412.davem@davemloft.net>
	 <1333631135.18626.606.camel@edumazet-glaptop>
	 <20120405.190509.409578034793502486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55194 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab2DFB7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 21:59:31 -0400
Received: by wgbdr13 with SMTP id dr13so1802087wgb.1
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 18:59:30 -0700 (PDT)
In-Reply-To: <20120405.190509.409578034793502486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-05 at 19:05 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 05 Apr 2012 15:05:35 +0200
> 
> > Hmm, thinking again about this, I did more tests and it appears we need
> > to differentiate the SPLICE_F_MORE flag (user request) and the internal
> > marker provided by splice logic (handling a batch of pages)
> > 
> > A program doing splice(... SPLICE_F_MORE) should really call tcp_push()
> > at the end of its work.
> 
> This is the kind of problem I was hoping we weren't introducing
> when I asked about sendfile() et al. the other day :-)

Yes, sorry for this.

Yet sendfile() did not have this problem (or so I believe), only the
splice(SPLICE_F_MORE) did.

Thanks

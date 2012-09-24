From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 13:11:52 -0400
Message-ID: <20120924171152.GA26454@redhat.com>
References: <20120905043523.GA12988@redhat.com>
 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
 <20120914212958.GA25053@redhat.com>
 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
 <20120919211059.GA10985@redhat.com>
 <1348092082.31352.51.camel@edumazet-glaptop>
 <20120920020223.GA28110@redhat.com>
 <20120924153921.GA13845@redhat.com>
 <1348504445.26828.1131.camel@edumazet-glaptop>
 <1348506011.26828.1195.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755934Ab2IXRMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 13:12:07 -0400
Content-Disposition: inline
In-Reply-To: <1348506011.26828.1195.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 24, 2012 at 07:00:11PM +0200, Eric Dumazet wrote:
 > Signed-off-by: Eric Dumazet <edumazet@google.com>
 > 
 > On Mon, 2012-09-24 at 18:34 +0200, Eric Dumazet wrote:
 > 
 > > OK, I believe I found the reason. I Will post a patch.
 > > 
 > > open a raw socket AF_INET, TCP_PROTO
 > > + connect() ->sk_state set to TCP_ESTABLISHED
 > > + setsockopt( SO_KEEPALIVE, &on)  -> crash
 > 
 > I confirm following patch fixes the problem for me.
 > 
 > Thanks again
 > 
 > [PATCH] net: guard tcp_set_keepalive() to tcp sockets
 > 
 > Its possible to use RAW sockets to get a crash in 
 > tcp_set_keepalive() / sk_reset_timer()
 > 
 > Fix is to make sure socket is a SOCK_STREAM one.

Great, I'll give this a shot.

Any idea why this only just started triggering ?
(Ie, do we need this for stable too?)

thanks,

	Dave

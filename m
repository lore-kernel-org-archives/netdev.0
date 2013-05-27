From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Mon, 27 May 2013 14:33:46 +0200
Message-ID: <20130527143346.2d19e854@redhat.com>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	<1369244868.3301.343.camel@edumazet-glaptop>
	<20130524151647.18388e27@redhat.com>
	<1369403496.3301.401.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932138Ab3E0Md5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 08:33:57 -0400
In-Reply-To: <1369403496.3301.401.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 May 2013 06:51:36 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2013-05-24 at 15:16 +0200, Jesper Dangaard Brouer wrote:
[...cut...]
> > I'm amazed, this patch will actually make it a viable choice to load
> > the conntrack modules on a DDoS based filtering box, and use the
> > conntracks to protect against ACK and SYN+ACK attacks.
> > 
> > Simply by not accepting the ACK or SYN+ACK to create a conntrack
> > entry. Via the command:
> >  sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
> > 
> > A quick test show; now I can run a LISTEN process on the port, and
> > handle an SYN+ACK attack of approx 2580Kpps (and the same for ACK
> > attacks), while running a LISTEN process on the port.
> > 
[...]
> > 
> 
> Wow, this is very interesting !
> 
> Did you test the thing when expectations are possible ? (say ftp
> module loaded)

Nope. I'm not sure how to create a test case, that causes an
expectation to be created.

> I think we should add RCU in the fast path, instead of having to lock
> the expectation lock. Its totally doable.

Interesting! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 2 Mar 2010 14:46:56 +0100
Message-ID: <20100302134656.GC20508@secunet.com>
References: <1267017564.3973.790.camel@bigi>
 <20100302112754.GA1513@gondor.apana.org.au>
 <1267531905.21749.21.camel@bigi>
 <20100302125156.GA2420@gondor.apana.org.au>
 <1267535426.21749.24.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	kaber@trash.net, yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:48687 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362Ab0CBNqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 08:46:31 -0500
Content-Disposition: inline
In-Reply-To: <1267535426.21749.24.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 08:10:26AM -0500, jamal wrote:
> On Tue, 2010-03-02 at 20:51 +0800, Herbert Xu wrote:
> 
> > Heh, you've just discovered a bug that I carefully planted back
> > in 2007, while merging the v4/v6 policy code :)
> 
> ;-> I am suprised it hasnt been noticed sooner given it accumulates
> memory on a per-packet basis.

The problem was spotted by 
commit a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
xfrm: select sane defaults for xfrm[4|6] gc_thresh

Before this commit, the xfrm garbage collector started to remove
stale bundle entries as soon as we reached an amount of 1024
bundle entries. Now the default value for the gc_thresh is
based on the main route table hash size, so we can have much more
bundle entries.

> 
> > It is a clear merging error, where *fl became rt->fl which is
> > totally different.  So please try this patch:
> > 
> 
> Looks like it would work.
> I dont have time right now - but will by either tonight or tomorrow
> evening. Steffen, if you have time - please go ahead and try it out
> as well.
> 

I tried it, works for me too.

Thanks,

Steffen

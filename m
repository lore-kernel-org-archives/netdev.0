From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 20 Sep 2004 08:34:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095683660.1047.254.camel@jzny.localdomain>
References: <414D0CCD.90209@eurodev.net>
	 <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040920025802.GA11567@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-09-19 at 22:58, Herbert Xu wrote:

> Well the ip_queue thing is simply a pipe that redirects packets going
> into netfilter to user space.  So we can't really stop that pipe when
> there is congestion.

You can detect congestion by noticing thresholds on the socket queue.
i.e high watermark to give opportunity to user space and low watermark
to let kernel piece continue.
To be honest you would probably need to do more (maybe borrow some ideas
from lazy receiver processing)to be precise - but thats a good start if
you can pull it.
At the moment the high watermark is the queue-fill level (in which case
an overrun happens) and low watermark is not defined. 

> AFAICT the problem Pablo is trying to solve is packet loss due to
> netlink congestion.
> 
> There might actually be a problem with the kernel not waking up the
> the user process when we tell it to.  It might even be a scheduling
> problem.  But we'll need a test-case to assess that.
> 

Agreed.
For a test i typically have something adding say 10K items (actions in
my case, but could be ipsec policies) and then try to dump them. On my
xeon i get an overrun after about 6K items are dumped.
-> Note that the overrun would have been a good enough a signal if you
could tell netlink "give me the rest of the stuff just before and
including the overrun". 

cheers,
jamal

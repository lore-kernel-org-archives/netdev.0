From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 19 Sep 2004 22:39:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095647944.1046.206.camel@jzny.localdomain>
References: <414D0CCD.90209@eurodev.net>
	 <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040919231734.GA10124@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-09-19 at 19:17, Herbert Xu wrote:
> Congestion control would be a good alternative to overruns.  I too would
> love to see netlink made more reliable if possible.  But hopefully without
> sacrificing the good bits in it like performance.

Agreed.
Note the fact that netlink can set the socket error flag provides it
with the workings needed for reliability i.e you get to know about lost
messages. If an overun occurs you (app) gets to know about it. You just
have to poll, unfortunately, for everything _again_.
 
> However, in the scenarios that's been cited so far I can't see how it can
> work.  For example, in the ip_queue context, the kernel really doesn't
> have any alternative to dropping the packet, right?

I havent paid a lot of attention to ip_queue workings. But something
that will get the kernel to backoff when a certain socket threshold gets
exceeded then get it going again when a below a low watermak. Dumps
already have markers stored in the callbacks, maybe something a long the
same line of thinking. You may have to tell user space "theres more
coming". Not sure how to achieve this, just brainstorming.
Essentially this is where the improvements over std overun signaling is,
IMO.

cheers,
jamal

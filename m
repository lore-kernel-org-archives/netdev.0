From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 21 Sep 2004 07:47:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095767265.1049.58.camel@jzny.localdomain>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	 <20040919120249.GA5963@gondor.apana.org.au> <414DF11C.1080505@eurodev.net>
	 <20040919215915.GB9573@gondor.apana.org.au>
	 <1095633569.1047.107.camel@jzny.localdomain>
	 <20040919231734.GA10124@gondor.apana.org.au>
	 <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040920215906.GA26266@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040920215906.GA26266@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-20 at 17:59, Herbert Xu wrote:

> > jamal wrote:
> >
> > >Agreed.
> > >For a test i typically have something adding say 10K items (actions in
> > >my case, but could be ipsec policies) and then try to dump them. On my
> > >xeon i get an overrun after about 6K items are dumped.
> 
> Good.  That's something we can look at easily.  Dumping is meant to
> be self-controlling as each packet naturally stops the next one from
> being sent until the user has done a recvmsg.

A get which results in a huge response (cant think of anything that
fits there - I have some stuff i havent released yet which applies) will
also have the same. Note by "large" implies it will overflow socket
buffer (and a setsock to increase the size will delay the problem from
happening).
Note, that an overrun in a dump results in lost messages. Maybe we can
detect that and reset the cb pointers appropriately? Have to look at the
code.

cheers,
jamal

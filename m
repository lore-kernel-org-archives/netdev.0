From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 21 Sep 2004 19:50:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921195040.483eaead.davem@davemloft.net>
References: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
	<20040919120249.GA5963@gondor.apana.org.au>
	<414DF11C.1080505@eurodev.net>
	<20040919215915.GB9573@gondor.apana.org.au>
	<1095633569.1047.107.camel@jzny.localdomain>
	<20040919231734.GA10124@gondor.apana.org.au>
	<1095647944.1046.206.camel@jzny.localdomain>
	<20040920025802.GA11567@gondor.apana.org.au>
	<1095683660.1047.254.camel@jzny.localdomain>
	<414F1E12.6010808@eurodev.net>
	<20040922000503.GA13218@gondor.apana.org.au>
	<4150E7E5.2000001@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4150E7E5.2000001@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think you should manage your "events" in your own data structure.
Perhaps a circular buffer of some sort.

Then provide ->dump() operation which fishes the events out of
the circular buffer.

That way you don't have to spam user space with a bunch of quick
transactions, you just wake him up once and several events may
be consumed and processed at once.

You can make your own buffering policies that way, and therefore
there is no need to complicate netlink for this purpose.

Meanwhile, I'm going to revert Pablo's original netlink optimization
until this is all sorted out.

From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sat, 11 Jun 2005 21:51:44 +0200
Message-ID: <20050611195144.GF28759__42379.2822439738$1118519389$gmane$org@alpha.home.local>
References: <20050611074350.GD28759@alpha.home.local> <E1DhBic-0005dp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DhBic-0005dp-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

On Sun, Jun 12, 2005 at 05:32:34AM +1000, Herbert Xu wrote:
> Willy Tarreau <willy@w.ods.org> wrote:
> > 
> > During this, the client cannot connect to www.kernel.org from this port
> > anymore :
> >  wks$ printf "HEAD / HTTP/1.0\r\n\r\n" | nc -p 10000 204.152.191.5 80; echo "ret=$?"
> >  ret=1
> 
> What if you let the client connect from a random port which is what it
> should do?

Of course, if the port chosen by the client is not in the range probed by
the attacker, everything's OK. My point is that relying *only* on a port
number is a bit limitative. It is even more when some protocols only bind
to privileged source ports, or always use the same port range at boot (eg:
a router establishing a BGP connection to the ISP's router).

Please note that if I only called it "small DoS", it's clearly because
I don't consider this critical, but I think that most people involved
in security will find that DoSes based on port guessing should be
addressed when possible.

Regards,
Willy

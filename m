From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Sun, 17 Oct 2004 13:08:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017110807.GV21977@postel.suug.ch>
References: <20041016113006.GA12843@gondor.apana.org.au> <20041016235137.GE19714@rei.reeler.org> <20041017073957.GA21632@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, hadi@cyberus.ca,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041017073957.GA21632@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20041017073957.GA21632@gondor.apana.org.au> 2004-10-17 17:39
> On Sun, Oct 17, 2004 at 01:51:37AM +0200, Thomas Graf wrote:
> > > So here is my proposal: if we detect signs of impending congestion
> > > in netlink_broadcast(), and that we're in a sleepable context, then
> > > we yield().
> > 
> > Up to how many receivers does that work? We would still see the
> > effect if too many receivers are registered, right?
> 
> Assuming the scheduler is fair then every listener should get their
> time slice to receive the messages.

Assuming there is only a few listeners per process. I tried it out and
my UP system could handle 7 listeners in the same process but would
sporadically overrun above. I couldn't reproduce it with 1 listener
per process anymore.

Therefore I guess this is fine for now, the problem might appear again
if someone finally writes the netlink daemon to solve the locking
problems.

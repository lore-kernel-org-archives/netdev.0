From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage socket
Date: Mon, 06 Apr 2015 22:03:48 -0700
Message-ID: <1428383028.25985.209.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150406.124114.924455461962119301.davem@davemloft.net>
	 <20150406.131700.185460014498109286.davem@davemloft.net>
	 <CALx6S35bZ6t9d+cpHRXYS94N6rGuHhACMAt9Bj6UzCwBuomBSA@mail.gmail.com>
	 <20150406.235118.65925113152002205.davem@davemloft.net>
	 <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org,
	=?UTF-8?Q?Ji=C5=99=C3=AD_P=C3=ADrko?= <jiri@resnulli.us>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-04-06 at 21:45 -0700, Tom Herbert wrote:
> On Mon, Apr 6, 2015 at 8:51 PM, David Miller <davem@davemloft.net> wrote:

> > I don't see what is convoluted about using the correct socket for
> > sending L3 protocol frames.  That's in fact how it's _supposed_ to
> > work.  And consistently having a proper matching socket available
> > makes it so that, long-term, we'll never have to deal with this issue
> > ever again.
> 
> I guess this is where I'm confused. We can send just about anything
> over GRE also, but have never needed a transmit socket for that. Is
> UDP encapsulation so different, or is GRE equally broken also? Also,
> will we need to add the socket to FOU and GUE then?

GRE encap is very low level (not L3), and no socket simply sends GRE
packets as is.

For example, when GSO support was extended, it was first extended to
GRE, and only later to other tunnels with more thinking about allowing
more sophisticated encap levels.



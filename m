From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Mon, 1 Dec 2003 15:22:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201152215.522c2447.davem@redhat.com>
References: <20031201201651.GA20194@gondor.apana.org.au>
	<20031201204700.GA20349@gondor.apana.org.au>
	<20031201135154.6906454c.davem@redhat.com>
	<20031201220509.GA20827@gondor.apana.org.au>
	<20031201142131.5da50a07.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031201142131.5da50a07.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Dec 2003 14:21:31 -0800
"David S. Miller" <davem@redhat.com> wrote:

> Let me think about this some more, maybe you're right and the
> error exists in both of these places.

Ok, I did my thinking :)

rt->rt_src is special.  It is the source address we have selected
to use with this route.  All output packets using this route must
use rt->rt_src as iph->saddr.

So, in effect, when we say "if (rt->rt_src == iph->saddr)" we
are asking the question "did we make this packet?"  I think this
is why Alexey coded the test in this way.

You are speaking of a case of zero source addresses.  When would
we output such an iph->saddr, by way of a route?  Right now this
is the only part I'm not seeing.

I want to be careful in changing this code, as loosening the key check
opens the possibility of new kinds of PMTU lowering attacks.
